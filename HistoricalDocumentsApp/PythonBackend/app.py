from flask import Flask, request, jsonify
from sqlalchemy import text, and_, or_
from database import SessionLocal, HistoricalDocument

app = Flask(__name__)

@app.route("/search")
def search():
    query = request.args.get("query", "").strip()
    title = request.args.get("title", "").strip()
    start_date = request.args.get("start_date", "").strip()
    end_date = request.args.get("end_date", "").strip()
    page = int(request.args.get("page", 1))
    limit = int(request.args.get("limit", 20))
    offset = (page - 1) * limit

    # Parse fallback years from dates
    start_year = 0
    end_year = 9999
    if start_date:
        try:
            start_year = int(start_date.split("-")[0])
        except:
            start_year = 0
    if end_date:
        try:
            end_year = int(end_date.split("-")[0])
        except:
            end_year = 9999

    # Decide whether to use the FTS table
    use_fts = bool(query)
    if use_fts:
        base_from = """
            FROM historical_documents_fts f
            JOIN historical_documents h ON f.rowid = h.id
        """
        where_clauses = ["f.text MATCH :query"]
    else:
        base_from = "FROM historical_documents h"
        where_clauses = []

    # Prepare parameters
    params = {
        "query": query,
        "title": f"%{title}%",
        "start_date": start_date,
        "end_date": end_date,
        "start_year": start_year,
        "end_year": end_year,
        "limit": limit,
        "offset": offset,
    }

    # Document‐type filter
    if title:
        where_clauses.append("h.doc_type LIKE :title")

    # Date / year filters
    if start_date and end_date:
        where_clauses.append("""
            (
                (date(h.effective_date) IS NOT NULL
                  AND date(h.effective_date) BETWEEN date(:start_date) AND date(:end_date))
                OR
                (date(h.effective_date) IS NULL
                  AND h.year BETWEEN :start_year AND :end_year)
            )
        """)
    elif start_date:
        where_clauses.append("""
            (
                (date(h.effective_date) IS NOT NULL
                  AND date(h.effective_date) >= date(:start_date))
                OR
                (date(h.effective_date) IS NULL
                  AND h.year >= :start_year)
            )
        """)
    elif end_date:
        where_clauses.append("""
            (
                (date(h.effective_date) IS NOT NULL
                  AND date(h.effective_date) <= date(:end_date))
                OR
                (date(h.effective_date) IS NULL
                  AND h.year <= :end_year)
            )
        """)

    # Build the WHERE clause
    where_clause = ""
    if where_clauses:
        where_clause = "WHERE " + " AND ".join(where_clauses)

    # Construct our SQL
    sql = f"SELECT h.* {base_from} {where_clause} LIMIT :limit OFFSET :offset"
    count_sql = f"SELECT COUNT(*) as total {base_from} {where_clause}"

    session = SessionLocal()
    results = session.execute(text(sql), params).fetchall()
    total_count = session.execute(text(count_sql), params).scalar()

    if not results:
        # Fallback to ORM if FTS returns nothing
        query_obj = session.query(HistoricalDocument)
        if query:
            query_obj = query_obj.filter(HistoricalDocument.text.contains(query))
        if title:
            query_obj = query_obj.filter(HistoricalDocument.doc_type.ilike(f"%{title}%"))

        # Reapply date/year filters in ORM
        from sqlalchemy import or_, and_
        if start_date and end_date:
            query_obj = query_obj.filter(
                or_(
                    and_(
                        HistoricalDocument.effective_date != None,
                        HistoricalDocument.effective_date != "",
                        HistoricalDocument.effective_date.between(start_date, end_date)
                    ),
                    and_(
                        or_(
                            HistoricalDocument.effective_date == None,
                            HistoricalDocument.effective_date == ""
                        ),
                        HistoricalDocument.year.between(start_year, end_year)
                    )
                )
            )
        elif start_date:
            query_obj = query_obj.filter(
                or_(
                    and_(
                        HistoricalDocument.effective_date != None,
                        HistoricalDocument.effective_date != "",
                        HistoricalDocument.effective_date >= start_date
                    ),
                    and_(
                        or_(
                            HistoricalDocument.effective_date == None,
                            HistoricalDocument.effective_date == ""
                        ),
                        HistoricalDocument.year >= start_year
                    )
                )
            )
        elif end_date:
            query_obj = query_obj.filter(
                or_(
                    and_(
                        HistoricalDocument.effective_date != None,
                        HistoricalDocument.effective_date != "",
                        HistoricalDocument.effective_date <= end_date
                    ),
                    and_(
                        or_(
                            HistoricalDocument.effective_date == None,
                            HistoricalDocument.effective_date == ""
                        ),
                        HistoricalDocument.year <= end_year
                    )
                )
            )

        total_count = query_obj.count()
        orm_results = query_obj.offset(offset).limit(limit).all()
        result_dicts = []
        for r in orm_results:
            d = r.__dict__.copy()
            d.pop('_sa_instance_state', None)
            result_dicts.append(d)
    else:
        result_dicts = [dict(row._mapping) for row in results]

    session.close()

    return jsonify({
        "results": result_dicts,
        "meta": {"total": total_count, "page": page, "limit": limit}
    })

if __name__ == "__main__":
    app.run(debug=True)

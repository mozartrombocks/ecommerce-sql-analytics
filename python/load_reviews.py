import pandas as pd
from sqlalchemy import create_engine
from urllib.parse import quote_plus

DB_USER = "****"
DB_PASSWORD = "****"
DB_HOST = "localhost"
DB_PORT = "****"
DB_NAME = "ecommerce_analytics"

csv_path = r"C:\Users\..."

encoded_password = quote_plus(DB_PASSWORD)

engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{encoded_password}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)
df = pd.read_csv(
    csv_path,
    encoding="latin1",
    dtype=str
)

date_cols = [
    "review_creation_date",
    "review_answer_timestamp"
]

for col in date_cols:
    df[col] = pd.to_datetime(df[col], errors="coerce")

print(df.head())
print(df.shape)

df.to_sql(
    "order_reviews",
    engine,
    if_exists="append",
    index=False,
    chunksize=1000,
    method="multi"
)
print("Loaded order_reviews successfully.")
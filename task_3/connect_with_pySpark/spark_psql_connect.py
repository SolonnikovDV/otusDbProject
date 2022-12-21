from pyspark.sql import SparkSession, SQLContext, DataFrameReader, DataFrame
import utils.config as cfg
from pyspark.sql.functions import monotonically_increasing_id, row_number
from pyspark.sql.window import Window

# local import
from utils.get_list_from_text import get_list_from_text


'''
to get path to a postgreSQL jdbc .jar file type in bash shell: $SPARK_HOME/jars & pwd
if you haven't 'postgresql-42.5.1.jar' then download it from https://jdbc.postgresql.org/download/
'''
# path to postgreSQL jdbc jar file
PATH_TO_PSQL_JAR = cfg.PATH_TO_PSQL_JAR

# connection args
HOST = cfg.HOST
PORT = cfg.PORT
DBNAME = cfg.DBNAME
USER = cfg.USER
PASSWORD = cfg.PASSWORD


# create connection to PostgreSQL
def create_session():
    return SparkSession \
        .builder \
        .appName("Python Spark SQL connection") \
        .config("spark.jars", f"{PATH_TO_PSQL_JAR}") \
        .getOrCreate()


# upload dataframe to a database table
def upload_dataframe_to_psql(df: DataFrame, table_name: str) -> None:
    # append data from Spark dataframe to PostgreSQL
    try:
        df.select('*').write.format("jdbc") \
            .option("url", f"jdbc:postgresql://{HOST}:{PORT}/{DBNAME}") \
            .option("driver", "org.postgresql.Driver") \
            .option("dbtable", f'{table_name}') \
            .option("user", f"{USER}") \
            .option("password", f"{PASSWORD}") \
            .mode("append") \
            .save()
        print(f'Export data to {DBNAME}.{table_name} is successful')
    except Exception as e:
        print(f'Export data to {DBNAME}.{table_name} is failure > {e}')


# read table from database to a spark dataframe
def read_psql(table_name: str) -> DataFrame:
    spark = create_session()
    try:
        df = spark.read \
            .format("jdbc") \
            .option("url", f"jdbc:postgresql://{HOST}:{PORT}/{DBNAME}") \
            .option("driver", "org.postgresql.Driver") \
            .option("dbtable", f"{table_name}") \
            .option("user", f"{USER}") \
            .option("password", f"{PASSWORD}") \
            .load()
        print(f'Read data from {DBNAME}.{table_name} is successful')
        # pyspark.sql.DataFrame type
        return df
    except Exception as e:
        print(f'Read data from {DBNAME}.{table_name} is failure > {e}')


if __name__ == '__main__':
    # read all tables in database
    list_of_tables = get_list_from_text('table_names.txt')
    for item in list_of_tables:
        read_psql(item).show()

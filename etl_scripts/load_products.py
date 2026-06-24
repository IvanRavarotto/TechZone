"""
=====================================================================================
Proyecto: TechZone - End-to-End Data Engineering Pipeline
Módulo: etl_scripts/load_products.py
Autor: Iván Ravarotto
Descripción: Módulo que contiene la lógica específica del proceso ETL.
             Destaca la implementación de Idempotencia (Upsert seguro) mediante el
             uso de tablas staging (temporales) en memoria y consultas SQL puras.
=====================================================================================
"""

import os
import pandas as pd
import logging
from datetime import datetime
from sqlalchemy import text

logger = logging.getLogger(__name__)

def extract_data(file_path):
    """Extrae los datos crudos desde un archivo CSV hacia un DataFrame de Pandas."""
    logger.info(f"📂 Extrayendo datos de: {file_path}")
    if not os.path.exists(file_path):
        logger.error("⚠️ Archivo no encontrado.")
        raise FileNotFoundError(f"Revisa que el archivo exista en la ruta: {file_path}")
    
    df = pd.read_csv(file_path)
    logger.info(f"✅ Se extrajeron {len(df)} filas del archivo fuente.")
    return df

def transform_data(df):
    """Aplica limpieza de datos y añade columnas de auditoría necesarias."""
    logger.info("⚙️ Transformando y limpiando datos...")
    
    # Eliminación de espacios en blanco en los nombres de las columnas
    df.columns = df.columns.str.strip()
    
    # Inyección de marca de tiempo para auditoría de inserción
    if 'product_datetime' not in df.columns:
        df['product_datetime'] = datetime.now()
        
    logger.info("✅ Transformación completada.")
    return df

def load_data(df, engine):
    """
    Carga los datos procesados a MySQL utilizando una estrategia UPSERT en 2 fases
    (Staging -> Update -> Insert -> Drop) para evitar la duplicación de registros.
    """
    logger.info(f"📊 Cargando {len(df)} productos a MySQL con lógica UPSERT...")
    try:
        # engine.begin() maneja automáticamente el COMMIT o ROLLBACK en caso de error
        with engine.begin() as conn:
            
            # 1. Crear tabla temporal (Staging) y volcar los datos de Pandas
            logger.info("⏳ Creando tabla temporal (staging)...")
            df.to_sql('product_staging', con=conn, if_exists='replace', index=False)
            
            logger.info("🔄 Ejecutando Upsert seguro...")
            
            # Paso 2A: Actualizar los productos que YA EXISTEN (match por product_name)
            update_query = text("""
                UPDATE PRODUCT p
                INNER JOIN product_staging s ON p.product_name = s.product_name
                SET p.product_price = s.product_price,
                    p.product_stock = s.product_stock,
                    p.product_datetime = s.product_datetime;
            """)
            conn.execute(update_query)
            
            # Paso 2B: Insertar SOLAMENTE los productos NUEVOS (los que no están en la BD)
            insert_query = text("""
                INSERT INTO PRODUCT (product_name, product_price, product_stock, product_datetime)
                SELECT s.product_name, s.product_price, s.product_stock, s.product_datetime
                FROM product_staging s
                WHERE s.product_name NOT IN (SELECT product_name FROM PRODUCT);
            """)
            conn.execute(insert_query)
            
            # 3. Borrar la tabla temporal para mantener limpia la base de datos
            logger.info("🧹 Eliminando tabla temporal...")
            conn.execute(text("DROP TABLE product_staging;"))
            
        logger.info("🚀 ¡Misión cumplida! Datos procesados correctamente sin duplicados.")
    except Exception as e:
        logger.error(f"❌ Fallo crítico al cargar a la BD: {e}")
        raise
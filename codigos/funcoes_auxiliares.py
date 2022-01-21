#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Importando Bibliotecas
import pandas as pd 
import numpy as np
import seaborn as sns
from pyproj import Transformer

def df_caracteristica(caracteristica, df_estado):
    '''Criação de dataframe da característica e plot da distribuição dos dados'''
    
    df = df_estado[[caracteristica, 'latitude', 'longitude']].dropna()
    df.reset_index(inplace=True, drop=True)
    lat_lon = df.copy()
    lat_lon = lat_lon.drop(caracteristica, axis=1)
    lat_lon.drop_duplicates(inplace=True)
    valores_unicos =pd.concat([df[caracteristica], lat_lon], axis=1)
    valores_unicos.dropna(inplace=True)
    sns.displot(valores_unicos, x=caracteristica,  kde=True, bins=20)
    return valores_unicos

def lat_lon_utm(df, atributo, zona):
    '''Função responsável por transformar Longitude e Latitude em UTM'''
    
    lat_lon = df.copy()
    trans = Transformer.from_crs(
    "epsg:4326",
    f"+proj=utm +zone={zona} +ellps=WGS84 +south=True",
    always_xy=True,
    )
        
    xx, yy = trans.transform(lat_lon["longitude"].values, lat_lon["latitude"].values)
    lat_lon["x"] = xx
    lat_lon["y"] = yy
    
    # Removendo casas decimais na UTM
    lat_lon['y'] = pd.to_numeric(lat_lon['y'].apply(lambda x: '%.0f' % x))
    lat_lon['x'] = pd.to_numeric(lat_lon['x'].apply(lambda x: '%.0f' % x))

    df_convertido = lat_lon.drop(['latitude', 'longitude'], axis=1)
    return df_convertido

def export_caracteristicas_escolhidas(lista, zona, estado, dic_df):
    '''Função responsável por exportar os dataframes'''
    
    for caracteristica in lista:
        df = dic_df[caracteristica]
        df_convertido = lat_lon_utm(df, caracteristica, zona)
        df_convertido.to_csv(f'../dados/dados_caracteristica/{estado}/{caracteristica}.csv', index=False)


# In[ ]:





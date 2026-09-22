SELECT * FROM public.ventas_colombia
ORDER BY id ASC LIMIT 100

SELECT * 
FROM public.ventas_colombia

/*
¿Cuál es el total de ingresos por ventas de cada producto?
¿Cuánto dinero se ha vendido en total por cada ciudad?
¿Cuáles son los productos con mayor cantidad de unidades vendidas?
¿Cuál es el monto total de ventas logrado por cada vendedor?
¿Cuántas ventas se han registrado con cada método de pago?
¿Cuál es el total de ventas mensuales a lo largo del tiempo?
¿Qué productos generan el mayor ingreso promedio por transacción?
¿Cuánto ingreso se obtuvo por cada categoría de producto?
¿Cuáles son los productos más vendidos en cantidad por cada ciudad?
¿Cuánto vendió cada vendedor en cada ciudad específica?
¿Cuál es el precio unitario promedio de cada producto?
¿Cuántas ventas se realizaron en cada año registrado?

*/

-- ¿Cuál es el total de ingresos por ventas de cada producto?
SELECT nombre_producto, SUM(precio_total) AS total_ingresos_por_producto
FROM public.ventas_colombia
GROUP BY nombre_producto
ORDER BY total_ingresos_por_producto DESC

-- ¿Cuánto dinero se ha vendido en total por cada ciudad?
SELECT ciudad, SUM(precio_total) AS total_ingresos_por_ciudad
FROM public.ventas_colombia
GROUP BY ciudad
ORDER BY total_ingresos_por_ciudad DESC

-- ¿Cuáles son los productos con mayor cantidad de unidades vendidas?
SELECT nombre_producto, SUM(cantidad) AS total_ventas_por_cantidad_por_producto
FROM public.ventas_colombia
GROUP BY nombre_producto
ORDER BY total_ventas_por_cantidad_por_producto DESC

-- ¿Cuál es el monto total de ventas logrado por cada vendedor?
SELECT nombre_vendedor, SUM(precio_total) AS total_ingresos_por_vendedor
FROM public.ventas_colombia
GROUP BY nombre_vendedor
ORDER BY total_ingresos_por_vendedor DESC

-- ¿Cuántas ventas se han registrado con cada método de pago?
SELECT metodo_pago, COUNT(metodo_pago) AS total_ventas_por_metodo_de_pago
FROM public.ventas_colombia
GROUP BY metodo_pago
ORDER BY total_ventas_por_metodo_de_pago DESC

-- ¿Cuál es el total de ventas mensuales a lo largo del tiempo?
SELECT EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha) AS mes, COUNT(*) AS total_ventas_por_mes
FROM public.ventas_colombia
GROUP BY EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)
ORDER BY EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha) ASC

-- ¿Qué productos generan el mayor ingreso promedio por transacción?
SELECT nombre_producto, ROUND(AVG(precio_total),0) AS promedio_ingresos_por_producto
FROM public.ventas_colombia
GROUP BY nombre_producto
ORDER BY promedio_ingresos_por_producto DESC

-- ¿Cuánto ingreso se obtuvo por cada categoría de producto?
SELECT tipo_producto, SUM(precio_total) AS total_ingresos_por_tipo_producto
FROM public.ventas_colombia
GROUP BY tipo_producto
ORDER BY total_ingresos_por_tipo_producto DESC

-- ¿Cuáles son los productos más vendidos en cantidad por cada ciudad?
WITH ventas_ciudad_producto AS (
    -- Paso 1: calculamos cantidad vendida de cada producto EN CADA CIUDAD
    SELECT 
        ciudad,
        nombre_producto,
        SUM(cantidad) AS cantidad_vendida
    FROM public.ventas_colombia
    GROUP BY ciudad, nombre_producto
),
ranking_por_ciudad AS (
    -- Paso 2: numeramos productos del más al menos vendido en cada ciudad
    SELECT 
        ciudad,
        nombre_producto,
        cantidad_vendida,
        ROW_NUMBER() OVER (PARTITION BY ciudad ORDER BY cantidad_vendida DESC) AS puesto
    FROM ventas_ciudad_producto
)
-- Paso 3: solo tomamos el #1 de cada ciudad
SELECT 
    ciudad,
    nombre_producto AS producto_mas_vendido,
    cantidad_vendida
FROM ranking_por_ciudad
WHERE puesto = 1
ORDER BY ciudad;

-- ¿Cuánto vendió cada vendedor en cada ciudad específica?
SELECT 
    nombre_vendedor,
    ciudad,
    COUNT(*) AS cantidad_de_ventas,
    SUM(precio_total) AS total_vendido
FROM public.ventas_colombia
GROUP BY nombre_vendedor, ciudad
ORDER BY nombre_vendedor, total_vendido DESC;

-- ¿Cuál es el precio unitario promedio de cada producto?
SELECT nombre_producto, ROUND(AVG(precio_unitario),0) AS precio_unitario_promedio_por_producto
FROM public.ventas_colombia
GROUP BY nombre_producto
ORDER BY precio_unitario_promedio_por_producto DESC

-- ¿Cuántas ventas se realizaron en cada año registrado?
-- Resumen completo por año (recomendado para portafolio)
SELECT
  EXTRACT(YEAR FROM fecha) AS anio,
  COUNT(*) AS cantidad_ventas,
  SUM(cantidad) AS unidades_vendidas,
  SUM(precio_total) AS ingreso_total,
  ROUND(AVG(precio_total), 0) AS promedio_por_venta
FROM public.ventas_colombia
GROUP BY EXTRACT(YEAR FROM fecha)
ORDER BY anio;
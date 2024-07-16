-- Active: 1721151338435@@127.0.0.1@5432@desafio3-Matias-Moncada-888
CREATE DATABASE "desafio3-Matias-Moncada-888";

CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    email VARCHAR(50) NOT NULL,
    nombre VARCHAR(30) NOT NULL,
    apellido VARCHAR(30) NOT NULL,
    rol VARCHAR(10) CHECK (rol IN ('admin',  'user'))
);

INSERT INTO usuarios (email, nombre, apellido, rol)
VALUES
    ('santigomez@gmail.com', 'Santiago', 'Gomez', 'admin'),
    ('jaimer99@hotmail.com', 'Jaime', 'Rodriguez', 'user'),
    ('apacheco77@gmail.com', 'Antonio', 'Pacheco', 'admin'),
    ('maggutierrez@hotmail.com', 'Magdalena', 'Gutierrez', 'user'),
    ('Michp66@gmail.com', 'Michelle', 'Perez', 'user');

    SELECT * FROM usuarios;

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(30) NOT NULL,
    contenido TEXT NOT NULL,
    fecha_creacion TIMESTAMP NOT NULL,
    fecha_actualizacion TIMESTAMP NOT NULL,
    destacado BOOLEAN NOT NULL,
    usuario_id BIGINT
);

INSERT INTO posts (titulo, contenido, fecha_creacion, fecha_actualizacion, destacado, usuario_id)
VALUES
    ('Terminos de Uso', 'Informacion basica terminos de uso...', '2024-06-20 8:00', '2024-06-27 12:32', true, 1),
    ('Reglas mandatorias', 'Seguir las siguientes reglas del grupo...', '2024-05-28 10:00', '2024-06-10 11:43', true, 1),
    ('Comandos basicos HTML', 'A continuacion explicaremos HTML...', '2024-06-22 14:00', '2024-06-22 14:00', false, 2),
    ('Comandos basicos CSS', 'A continuacion explicaremos CSS de manera...', '2024-06-28 17:30', '2024-06-28 17:30', false, 4),
    ('Comandos basicos JS', 'A continuacion una intro a JS...', '2024-07-03 18:00', '2024-07-03 18:00', false, NULL);

CREATE TABLE comentarios (
    id SERIAL PRIMARY KEY,
    contenido TEXT,
    fecha_creacion TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT
);

INSERT INTO comentarios (contenido, fecha_creacion, usuario_id, post_id)
VALUES
    ('Hola gente, estos son los terminos de uso basicos cualquier consulta...', '2024-06-20 8:10', 1, 1),
    ('Hola Santi, tenia una duda sobre la privacidad y como se almacena...', '2024-06-23 19:00', 2, 1),
    ('Hola Jaime, mira con eso te puedo ayudar yo, en la linea 22 de los...', '2024-06-24 8:00', 3, 1),
    ('Hola grupo, aca les pongo las reglas para que mantengamos un...', '2024-05-28 10:10', 1, 2),
    ('Santi hasta que nivel un meme se considera irrespetuoso o que...', '2024-05-30 14:00', 2, 2);

-- 1. Crea y agrega al entregable las consultas para completar el setup de acuerdo a lo pedido.
-- 2. Cruza los datos de la tabla usuarios y posts, mostrando las siguientes columnas: nombre y email del usuario junto al título y contenido del post.

SELECT u.nombre, u.email, p.titulo, p.contenido
FROM usuarios AS u
INNER JOIN posts AS p ON u.id = p.usuario_id;

-- 3. Muestra el id, título y contenido de los posts de los administradores.       a. El administrador puede ser cualquier id.

SELECT p.id, p.titulo, p.contenido 
FROM posts AS p 
INNER JOIN usuarios AS u ON u.id = p.usuario_id
WHERE u.rol = 'admin';

-- 4. Cuenta la cantidad de posts de cada usuario.     a. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.

SELECT u.email, u.id, COUNT(p.id) AS post_count
FROM usuarios AS u
LEFT JOIN posts AS p ON u.id = p.usuario_id
GROUP BY u.email, u.id
ORDER BY post_count DESC;

-- 5. Muestra el email del usuario que ha creado más posts.     a. Aquí la tabla resultante tiene un único registro y muestra solo el email.


SELECT u.email
FROM usuarios AS u
INNER JOIN (
    SELECT usuario_id, COUNT(*) AS post_count
    FROM posts
    GROUP BY usuario_id
    ORDER BY post_count DESC
    LIMIT 1
) p ON u.id = p.usuario_id
LIMIT 1;

-- 6. Muestra la fecha del último post de cada usuario.

SELECT u.nombre, MAX(p.fecha_creacion) AS last_post_date
FROM usuarios AS u
LEFT JOIN posts AS p ON u.id = p.usuario_id
GROUP BY u.nombre
ORDER BY last_post_date DESC;

-- 7. Muestra el título y contenido del post (artículo) con más comentarios.

SELECT p.titulo, p.contenido
FROM posts AS p
INNER JOIN (
    SELECT post_id, COUNT(*) AS comment_count
    FROM comentarios
    GROUP BY post_id
    ORDER BY comment_count DESC
    LIMIT 1
) AS c ON p.id = c.post_id;

-- 8. Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió.

SELECT p.titulo, p.contenido AS post_contenido, c.contenido AS comment_contenido, u.email
FROM posts AS p
LEFT JOIN comentarios AS c ON p.id = c.post_id
LEFT JOIN usuarios AS u ON c.usuario_id = u.id
ORDER BY p.id;

--  9. Muestra el contenido del último comentario de cada usuario.

SELECT c.contenido AS last_comment
FROM comentarios c
INNER JOIN (
    SELECT usuario_id, MAX(fecha_creacion) AS max_fecha
    FROM comentarios
    GROUP BY usuario_id
) AS latest_comments
ON c.usuario_id = latest_comments.usuario_id
AND c.fecha_creacion = latest_comments.max_fecha;

-- 10. Muestra los emails de los usuarios que no han escrito ningún comentario

SELECT u.email
FROM usuarios AS u
WHERE u.id NOT IN (
    SELECT usuario_id
    FROM comentarios
    GROUP BY usuario_id
    HAVING COUNT(*) > 0
);
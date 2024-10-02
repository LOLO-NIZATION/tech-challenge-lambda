// Importando bibliotecas necessárias
const mysql = require('mysql2/promise');

// Função Lambda principal
exports.handler = async (event) => {
  const { cpf } = event;

  // Configuração de conexão com o banco MySQL
  const connectionConfig = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  };

  // Validação básica do CPF
  if (!cpf || cpf.length !== 11) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'CPF inválido' }),
    };
  }

  // Query SQL para verificar o CPF no banco de dados
  const query = 'SELECT * FROM Cliente WHERE Cpf = ?';

  try {
    const connection = await mysql.createConnection(connectionConfig);

    const [rows] = await connection.execute(query, [cpf]);

    await connection.end();

    if (rows.length > 0) {
      return {
        statusCode: 200,
        body: JSON.stringify({ message: 'CPF encontrado', data: rows[0] }),
      };
    } else {
      return {
        statusCode: 404,
        body: JSON.stringify({ message: 'CPF não encontrado' }),
      };
    }
  } catch (error) {
    console.error('Erro ao conectar ao MySQL:', error);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: 'Erro ao consultar a base de dados', error }),
    };
  }
};
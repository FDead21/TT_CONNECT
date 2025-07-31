const oracledb = require('oracledb');

const dbConfig = {
  user: process.env.ORACLE_USER,
  password: process.env.ORACLE_PASSWORD,
  connectString: `${process.env.ORACLE_HOST}:${process.env.ORACLE_PORT}/${process.env.ORACLE_SERVICE}`
};

async function initialize() {
  try {
    await oracledb.createPool({
      ...dbConfig,
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 1,
      poolTimeout: 300
    });
    console.log('Oracle connection pool started');
  } catch (err) {
    console.error('Oracle pool initialization failed:', err);
  }
}

async function close() {
  try {
    await oracledb.getPool().close(10);
    console.log('Oracle connection pool closed');
  } catch (err) {
    console.error('Error closing Oracle pool:', err);
  }
}

module.exports = { initialize, close };
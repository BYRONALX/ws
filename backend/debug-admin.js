const { Sequelize } = require("sequelize");
const bcrypt = require("bcryptjs");
const path = require("path");
require("dotenv").config();

// Attempt to load database config from the compiled dist folder
// This path is relative to where this script is run (backend root)
const dbConfigPath = path.resolve(__dirname, "dist", "config", "database.js");
console.log(`Carregando config do banco de: ${dbConfigPath}`);

let dbConfig;
try {
  dbConfig = require(dbConfigPath);
} catch (e) {
  console.error("❌ Erro ao carregar configuração do banco. Certifique-se que o projeto foi 'buildado' (tem a pasta dist).");
  console.error(e);
  process.exit(1);
}

// Adjust config if needed (sometimes it exports 'module.exports = { ... }' or 'default')
// Checking if it's wrapped in 'default' property (common in TS compilation)
const config = dbConfig.default || dbConfig;

async function debugAdmin() {
  console.log("🔍 Iniciando diagnóstico do usuário ADMIN...");
  console.log(`📡 Conectando ao Banco de Dados: ${config.host}:${config.port} / DB: ${config.database} / User: ${config.username}`);

  const sequelize = new Sequelize(config.database, config.username, config.password, {
    host: config.host,
    port: config.port,
    dialect: config.dialect,
    logging: false, // Turn off noise
    dialectOptions: config.dialectOptions
  });

  try {
    await sequelize.authenticate();
    console.log("✅ Conexão com Banco de Dados estabelecida!");
  } catch (error) {
    console.error("❌ Falha na conexão com o banco:", error.message);
    process.exit(1);
  }

  try {
    // Check if table exists
    const [tables] = await sequelize.query(`SELECT table_name FROM information_schema.tables WHERE table_schema='public' AND table_name='Users'`);
    if (tables.length === 0) {
      console.error("❌ TABELA 'Users' NÃO ENCONTRADA! As migrações não rodaram.");
      return;
    }

    // Query for Admin
    const [users] = await sequelize.query(`SELECT * FROM "Users" WHERE email = 'admin@admin.com' LIMIT 1`);
    
    if (users.length === 0) {
      console.log("❌ Usuário 'admin@admin.com' NÃO ENCONTRADO no banco!");
      
      const [allUsers] = await sequelize.query(`SELECT count(*) as count FROM "Users"`);
      console.log(`   Total de usuários no banco: ${allUsers[0].count}`);
      console.log("👉 DICA: Se o total for 0, os Seeds não rodaram. Se for >0, talvez o email seja outro.");
    } else {
      const user = users[0];
      console.log("✅ Usuário ENCONTRADO!");
      console.log("--------------------------------------------------");
      console.log(`ID: ${user.id}`);
      console.log(`Nome: ${user.name}`);
      console.log(`Email: ${user.email}`);
      console.log(`Profile: ${user.profile}`);
      console.log(`CompanyId: ${user.companyId}`);
      console.log(`Hash Senha: ${user.passwordHash ? user.passwordHash.substring(0, 15) + "..." : "NULL"}`);
      console.log("--------------------------------------------------");

      // Test Password
      if (!user.passwordHash) {
        console.log("❌ O usuário não tem hash de senha!");
      } else {
        const isMatch = await bcrypt.compare("123456", user.passwordHash);
        if (isMatch) {
          console.log("✅ Senha '123456' bate com o hash no banco. O login DEVERIA funcionar.");
          console.log("👉 Se ainda não loga, verifique:");
          console.log("   1. Se o CompanyId=1 existe (vou checar...)");
          console.log("   2. Se há erro no console do navegador (CORS, 403, 500).");
        } else {
          console.log("❌ Senha '123456' NÃO bate com o hash!");
          console.log("⚠️  RESETANDO SENHA PARA 123456 AGORA...");
          
          const newHash = await bcrypt.hash("123456", 8);
          await sequelize.query(`UPDATE "Users" SET "passwordHash" = '${newHash}' WHERE id = ${user.id}`);
          console.log("✅ Senha atualizada no banco. Tente logar novamente.");
        }
      }

      // Check Company
      const [companies] = await sequelize.query(`SELECT * FROM "Companies" WHERE id = ${user.companyId}`);
      if (companies.length === 0) {
        console.log(`❌ Company ID ${user.companyId} NÃO EXISTE! O usuário está órfão.`);
      } else {
        console.log(`✅ Company ID ${user.companyId} existe.`);
      }
    }

  } catch (error) {
    console.error("❌ Erro durante diagnóstico:", error);
  } finally {
    await sequelize.close();
  }
}

debugAdmin();

import dotenv from "dotenv";
import fastify from "fastify";
import macos from "./macos";

const port = process.env.PORT || 3000;
const address = process.env.HOST || "0.0.0.0";

dotenv.config();

const server = fastify({
  logger: true,
  trustProxy: true,
});

macos(server);

const start = async () => {
  try {
    await server.listen(port, address);
    console.log(`listening on port: ${port} and address: ${address}`);
  } catch (err) {
    server.log.error(err);
    console.error(err);
    process.exit(1);
  }
};

start();

import asyncio
import websockets

clientes = set()

async def chat(websocket):
    cliente_id = id(websocket)
    print(f"Cliente conectado: {cliente_id}")
    clientes.add(websocket)
    
    try:
        async for message in websocket:
            mensagem_formatada = f"{message} from {cliente_id}"
            print(f"Mensagem recebida: {mensagem_formatada}")

            # Envia a mensagem para todos os clientes conectados
            for cliente in clientes:
                await cliente.send(mensagem_formatada)
    except websockets.ConnectionClosed:
        print(f"Conexão perdida com o cliente: {cliente_id}")
    finally:
        clientes.remove(websocket)
        print(f"Cliente desconectado: {cliente_id}")

async def main():
    async with websockets.serve(chat, "localhost", 8765):
        print("Servidor WebSocket iniciado em ws://localhost:8765")
        await asyncio.Future()  # Mantém o servidor rodando

# Executa o servidor WebSocket
asyncio.run(main())
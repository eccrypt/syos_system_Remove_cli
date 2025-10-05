package com.syos.websocket;

import java.io.IOException;
import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

@ServerEndpoint("/realtime-updates")
public class RealtimeWebSocketEndpoint {

    private final RealtimeBroadcastService broadcastService = RealtimeBroadcastService.getInstance();

    @OnOpen
    public void onOpen(Session session) {
        System.out.println("WebSocket connection opened: " + session.getId());
        broadcastService.addSession(session);

        // Send welcome message
        try {
            session.getBasicRemote().sendText("{\"eventType\":\"CONNECTED\",\"data\":{\"message\":\"Connected to real-time updates\"},\"timestamp\":" + System.currentTimeMillis() + "}");
        } catch (IOException e) {
            System.err.println("Error sending welcome message: " + e.getMessage());
        }
    }

    @OnClose
    public void onClose(Session session) {
        System.out.println("WebSocket connection closed: " + session.getId());
        broadcastService.removeSession(session);
    }

    @OnMessage
    public void onMessage(String message, Session session) {
        System.out.println("Received WebSocket message: " + message);
        // For now, we don't expect messages from clients
        // This could be extended for client-initiated requests
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("WebSocket error for session " + session.getId() + ": " + throwable.getMessage());
        broadcastService.removeSession(session);
    }
}
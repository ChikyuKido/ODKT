using System;
using System.Net.WebSockets;
using System.Threading;

public class WebsocketManager {
    private ClientWebSocket _client = new();

    public String ConnectTo(String url) {
        if (_client.State == WebSocketState.Open || _client.State == WebSocketState.Connecting) {
            return "Connection already open";
        }
        _client.Options.SetRequestHeader("Authentication","Bearer "+Globals.Instance.JwtToken);
        _client.ConnectAsync(new Uri(url), CancellationToken.None);
        return "";
    }
}
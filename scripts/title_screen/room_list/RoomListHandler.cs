using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using Godot;
using HttpClient = System.Net.Http.HttpClient;

public partial class RoomListHandler : Node {
    private readonly HttpClient _httpClient = new HttpClient();
    [Export] private Control _roomContainer;
    [Export] private PackedScene _roomItem;

    public override void _Ready() {
        SearchRooms();
    }

    private async void SearchRooms() {
        ClearRooms();
        await GetRooms();
    }

    private async Task GetRooms() {
        var url = Globals.Instance.Url + "/api/v1/room/list";
        var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Add("Authentication", "Bearer " + Globals.Instance.JwtToken);

        try {
            HttpResponseMessage response = await _httpClient.SendAsync(request);
            var responseBody = await response.Content.ReadAsStringAsync();
            if (!response.IsSuccessStatusCode) {
                GD.Print("Could not load rooms: " + responseBody);
                return;
            }

            var jsonResponse = JsonSerializer.Deserialize<Dictionary<string, object>>(responseBody);
            var rooms = JsonSerializer.Deserialize<List<Dictionary<string, object>>>(jsonResponse["rooms"].ToString());
            GD.Print("Room List: " + JsonSerializer.Serialize(rooms));
            foreach (var room in rooms) CreateRoom(room);
        }
        catch (Exception ex) {
            GD.Print("Error fetching rooms: " + ex.Message);
        }
    }

    private void CreateRoom(Dictionary<string, object> roomData) {
        var room = (Control)_roomItem.Instantiate();
        var roomParent = (Control)room.GetChild(0).GetChild(0).GetChild(0);
        ((RichTextLabel)roomParent.GetChild(1).GetChild(0)).Text = roomData["name"].ToString();
        ((RichTextLabel)roomParent.GetChild(1).GetChild(1).GetChild(0)).Text =
            $"Owner: {roomData["owner_name"]}\nPlayers: {roomData["players"]}/{roomData["max_players"]}";
        string roomId = roomData["uuid"].ToString();
        ((Button)roomParent.GetChild(2).GetChild(0)).Connect("pressed", Callable.From(OnRoomButtonPressed(roomId)));
        _roomContainer.AddChild(room);
    }
    private Action OnRoomButtonPressed(string roomId) {
        return () => {
            GD.Print("Room ID: " + roomId);
        };
    }

    private void ClearRooms() {
        foreach (var child in _roomContainer.GetChildren()) child.QueueFree();
    }
}
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Godot;
using HttpClient = System.Net.Http.HttpClient;

public partial class AuthHandler : Node {
    private readonly HttpClient _httpClient = new();
    [Export] private RichTextLabel _errorText;
    [Export] private LineEdit _passwordEdit;
    [Export] private LineEdit _urlEdit;
    [Export] private LineEdit _usernameEdit;

    private async void Login() {
        await SendRequest("/api/v1/auth/login", "Successfully logged in.", "Failed to login: ");
    }

    private async void Register() {
        await SendRequest("/api/v1/auth/register", "Successfully created account. You can now login",
            "Failed to register: ");
    }

    private async Task SendRequest(string endpoint, string successMessage, string failureMessage) {
        var url = "http://" + _urlEdit.Text + endpoint;
        var requestData = new Dictionary<string, string> {
            { "username", _usernameEdit.Text },
            { "password", _passwordEdit.Text }
        };
        var jsonBody = JsonSerializer.Serialize(requestData);
        var content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

        try {
            var response = await _httpClient.PostAsync(url, content);
            var responseBody = await response.Content.ReadAsStringAsync();
            var jsonResponse = JsonSerializer.Deserialize<Dictionary<string, object>>(responseBody);

            _errorText.Visible = true;
            _errorText.Clear();

            if (!response.IsSuccessStatusCode) {
                _errorText.PushColor(new Color("red"));
                _errorText.AppendText(response.StatusCode + ": " + failureMessage + jsonResponse["error"]);
            }
            else {
                _errorText.PushColor(new Color("green"));
                _errorText.AppendText(successMessage);
                if (endpoint.Contains("login")) {
                    Globals.Instance.JwtToken = jsonResponse["jwt"].ToString();
                    Globals.Instance.Url = "http://" + _urlEdit.Text;
                    GetTree().ChangeSceneToFile("res://scene/title_screen.tscn");
                }
            }
        }
        catch (Exception ex) {
            _errorText.Visible = true;
            _errorText.PushColor(new Color("red"));
            _errorText.AppendText("Error: " + ex.Message);
        }
    }
}
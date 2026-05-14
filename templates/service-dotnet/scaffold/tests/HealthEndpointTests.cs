using System.Net;
using Microsoft.AspNetCore.Mvc.Testing;

namespace Service.Tests;

public sealed class HealthEndpointTests(WebApplicationFactory<Program> factory)
    : IClassFixture<WebApplicationFactory<Program>>
{
    [Fact]
    public async Task HealthEndpointReturnsOk()
    {
        var client = factory.CreateClient();
        var response = await client.GetAsync("/health");

        Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    }
}

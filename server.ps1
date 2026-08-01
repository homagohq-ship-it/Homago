$http = New-Object System.Net.HttpListener
$http.Prefixes.Add("http://localhost:3000/")
$http.Start()
Write-Host "Server running on http://localhost:3000/"

while ($http.IsListening) {
    try {
        $context = $http.GetContext()
        $request = $context.Request
        $response = $context.Response

        $path = [System.Uri]::UnescapeDataString($request.Url.LocalPath)
        if ($path -eq "/") { $path = "/index.html" }
        $localPath = Join-Path (Get-Location) ($path.TrimStart('/').Replace('/', '\'))

        if (Test-Path $localPath -PathType Leaf) {
            $content = [System.IO.File]::ReadAllBytes($localPath)
            $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
            switch ($ext) {
                ".html" { $response.ContentType = "text/html; charset=utf-8" }
                ".css"  { $response.ContentType = "text/css" }
                ".js"   { $response.ContentType = "application/javascript" }
                ".png"  { $response.ContentType = "image/png" }
                ".jpg"  { $response.ContentType = "image/jpeg" }
                ".svg"  { $response.ContentType = "image/svg+xml" }
                ".json" { $response.ContentType = "application/json" }
                default { $response.ContentType = "application/octet-stream" }
            }
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            $response.StatusCode = 404
        }
        $response.Close()
    } catch {
        # ignore context errors on shutdown
    }
}

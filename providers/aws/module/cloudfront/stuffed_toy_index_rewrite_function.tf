# CloudFront Function: S3 frontend オリジンに対する URI 正規化
# Next.js static export (trailingSlash: true) を S3 から配信するために必要。
#
#   /                  -> /index.html
#   /about/            -> /about/index.html
#   /about             -> /about/index.html  （拡張子なしのパスをディレクトリ扱い）
#   /_next/static/x.js -> 変更なし（拡張子あり）
#   /favicon.ico       -> 変更なし
#
# default_cache_behavior（S3 frontend）にのみ attach する。
# /api/* / /ws/* / /healthz は ALB へそのまま透過するので適用しない。

resource "aws_cloudfront_function" "stuffed_toy_index_rewrite" {
  name    = "stuffed-toy-index-rewrite-${var.env_value_environment}"
  runtime = "cloudfront-js-2.0"
  publish = true

  code = <<-EOT
    function handler(event) {
      var request = event.request;
      var uri = request.uri;

      if (uri.endsWith('/')) {
        request.uri = uri + 'index.html';
      } else if (!uri.split('/').pop().includes('.')) {
        request.uri = uri + '/index.html';
      }

      return request;
    }
  EOT
}

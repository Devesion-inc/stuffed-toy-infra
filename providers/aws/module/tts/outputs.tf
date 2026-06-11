
output "stuffed_toy_tts_instance_id" {
  value = aws_instance.stuffed_toy_tts.id
}

output "stuffed_toy_tts_private_ip" {
  value = aws_instance.stuffed_toy_tts.private_ip
}

output "stuffed_toy_tts_public_ip" {
  value = aws_eip.stuffed_toy_tts.public_ip
}

output "stuffed_toy_tts_endpoint" {
  description = "アプリ側 (api/relay) から呼び出す TTS エンドポイント（VPC 内通信は private IP を使う）"
  value       = "http://${aws_instance.stuffed_toy_tts.private_ip}:${var.container_port}"
}

output "stuffed_toy_tts_security_group_id" {
  value = aws_security_group.stuffed_toy_tts.id
}

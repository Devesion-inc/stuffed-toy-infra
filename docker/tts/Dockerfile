# Aivis 音声合成エンジン + カスタム音声モデル
#
# このディレクトリ直下に置いた .aivmx を全部 image に焼き込みます。
# 複数モデルなら複数 .aivmx を置くだけで OK。

FROM ghcr.io/aivis-project/aivisspeech-engine:nvidia-latest

# このディレクトリの全 .aivmx を Aivis のモデルディレクトリへ
COPY *.aivmx /home/user/.local/share/AivisSpeech-Engine-Dev/Models/

# 所有者を Aivis container の実行ユーザ (uid 1000) に揃える
RUN chown -R 1000:1000 /home/user/.local/share/AivisSpeech-Engine-Dev

# AGENTS.md — xinlu_grain_valley

芯麓谷物语 — 移动端像素风农场模拟 RPG

## 命令
```bash
make test          # flutter test
make analyze       # flutter analyze
make format        # dart format .
make build-android # flutter build apk --release
make gen           # dart run build_runner build --delete-conflicting-outputs\nmake run           # flutter run
```

## 技术栈
Flutter / Dart 3.12+

## 约定
- Lint: flutter_lints + 自定义规则
- 测试文件在 `test/` 目录
- Service 层返回 Result<T>

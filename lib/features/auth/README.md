# Auth Feature (Clean Architecture)

This module implements:
- Register (`POST /api/v1/auth/register`)
- Login (`POST /api/v1/auth/login`)
- Refresh token (`POST /api/v1/auth/refresh-token`)
- Logout (`POST /api/v1/auth/logout`)
- Forgot password (`POST /api/v1/auth/forgot-password`)

## Folder layout

- `data/`: API datasource, models, repository implementation, token storage, Dio interceptor.
- `domain/`: entities, repository contract, use cases.
- `providers/`: Riverpod DI + auth state/controller.
- `pages/`: `AuthGate`, `LoginPage`, `RegisterPage`, `ForgotPasswordPage`.
- `widgets/`: reusable auth form widgets.

## Important integration notes

1. Set your real backend base URL in `lib/core/network/api_providers.dart` (`BaseOptions.baseUrl`).
2. Auth is currently configured with a mock-first toggle in `lib/features/auth/providers/auth_providers.dart`:
   - default: `USE_MOCK_AUTH=true` (works without backend)
   - when backend is ready, run/build with `--dart-define=USE_MOCK_AUTH=false`
2. `AuthInterceptor` automatically:
   - attaches `Authorization: Bearer <accessToken>`
   - refreshes token on `401`
   - retries original request after successful refresh
   - clears tokens and triggers session reset when refresh fails
3. App startup flow is in `lib/main.dart` -> `AuthGate`.
4. Tokens are stored securely with `flutter_secure_storage` (not SharedPreferences).

## Security

- Access/refresh tokens are saved in secure storage.
- Inputs validated in UI forms.
- Duplicate auth requests prevented by `_busy` guard in `AuthController`.
- API errors are mapped to user-friendly messages.

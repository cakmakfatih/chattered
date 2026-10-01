# Chattered

Chattered çalışma alanı, mobil uygulama ve API projelerini ayrı Git depoları olarak submodule biçiminde bir araya getirir.

## Dizinler

- `mobile/`: Expo ve React Native mobil uygulaması (Git submodule).
- `server/`: Gin tabanlı Go API'si (Git submodule).
- `docker/`: Geliştirme ortamı için `compose.dev.yml` dosyası; dosya şimdilik boştur.

Her submodule kendi Git geçmişini ve `dev` branch'ini korur. Ana depo, her modülün kullandığı commit'i kaydeder. Bu kurulumda modül remote'ları yerel bare depolardır: `D:/Chattered-remotes/server.git` ve `D:/Chattered-remotes/mobile.git`. Başka bir makinede kullanmak için `.gitmodules` içindeki URL'leri erişilebilir remote URL'leriyle değiştirin.

Submodule'leri başlatmak veya güncellemek için:

```sh
git submodule update --init --recursive
```

## Başlangıç

1. `mobile/.env.example` dosyasını `mobile/.env` olarak kopyalayıp Clerk publishable key'i ekleyin. Mobil Clerk akışı için Clerk Dashboard'da Native API'yi etkinleştirin.
2. `server/.env.example` dosyasını `server/.env` olarak kopyalayıp Clerk secret key'i ekleyin.
3. API'yi hot reload ile çalıştırmak için `server/` dizininde `go tool air` komutunu kullanın.
4. Mobil uygulamayı başlatmak için `mobile/` dizininde `npm install` ve `npx expo start` komutlarını kullanın.

Mobil cihazdan yerel API'ye erişirken `localhost` yerine bilgisayarın yerel ağ IP adresini kullanın.

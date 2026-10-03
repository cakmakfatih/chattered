# Chattered

Chattered ana deposu, mobil uygulama, API ve background worker projelerini ayrı Git depoları olarak submodule biçiminde bir araya getirir. Ana depo her modül için kullanılacak commit'i kaydeder.

## Dizinler

- `mobile/`: Expo ve React Native mobil uygulaması (Git submodule).
- `server/`: Gin tabanlı Go API'si (Git submodule).
- `background/`: Asynq kullanan Go background worker (Git submodule).
- `docker/`: PostgreSQL, Redis ve background worker için `compose.dev.yml`.

Her submodule kendi Git geçmişini ve `dev` branch'ini korur. Bu depolar private olduğu için klonlayacak GitHub hesabının ana depoya ve üç submodule deposuna da erişimi olmalıdır.

## Klonlama

Submodule'leriyle birlikte klonlamak için:

```sh
git clone --recurse-submodules https://github.com/cakmakfatih/chattered.git
```

Depo daha önce submodule'ler olmadan klonlandıysa bunları başlatmak için:

```sh
git submodule update --init --recursive
```

## Geliştirme ortamı

1. Ana dizindeki `.env.example` dosyasını `.env.dev` olarak kopyalayıp parola yer tutucularını değiştirin.
2. Servisleri başlatmak için `docker compose -f docker/compose.dev.yml up --build` komutunu çalıştırın.
3. `mobile/.env.example` dosyasını `mobile/.env` olarak kopyalayıp Clerk publishable key'i ve API adresini girin. Mobil Clerk akışı için Clerk Dashboard'da Native API'yi etkinleştirin.
4. `server/.env.example` dosyasını `server/.env` olarak kopyalayıp Clerk secret key'i ve veritabanı adresini girin.
5. API'yi hot reload ile çalıştırmak için `server/` dizininde `go tool air` komutunu kullanın.
6. Mobil uygulamayı başlatmak için `mobile/` dizininde `npm install` ve `npx expo start` komutlarını kullanın.

Mobil cihazdan yerel API'ye erişirken `localhost` yerine bilgisayarın yerel ağ IP adresini kullanın.

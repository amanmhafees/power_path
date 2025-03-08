/*import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    // Get the server key from the server
    // This is a dummy implementation
    final scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.messaging",
      "https://www.googleapis.com/auth/firebase.database",
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          "type": "service_account",
          "project_id": "power-path-c1bb4",
          "private_key_id": "c84361ec9261847ad19461cad5046dac5ba94805",
          "private_key":
              "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDdm9avJjIDC+ic\nPY74LpDPaZvjpaQ1Q9PCq5z57XKzqNSPRS/3tVK/qcKpakvFCssLRUFjZ1lssBKL\nsBI6zx1MTTtg587cFhgyOdp7Ki3dI1tCsQBtVWD62Ypd/FazF1XP1QbSh5GsSY+x\naNQUkTMut6OJbk+1wDy3WGYe4JjjKRZYpWnuuYoXaNPMVBJJXS7BeLXiYMeTui1M\n1FMOc6p9q7RxIhl2rJe5e7+g42bDa3dU5pN7PU7gdAgrgZgpVlnW6WTmo91NOIrU\nh3k+otwUQz2ym5yAxMdbb8VBWxRaV5h//YrlZOX5oeIMPNBDsELUbwLdfRDC96Hk\nmGbFtLiVAgMBAAECggEACwkJGkS1JdiwdyNLnMk41dNE+4OSl0Ju55lDImD0HsUv\n/Iht+JBTdA7gji4oYsIEVWXX+Tq6xcJI0iLs7XfF1jhcVhmFAAmrn8iovAxgJ0xs\n7XfB9S/UufkePkrkCFwHnmdVxSMSGnm5SZTWRsXqPg/P+XaASqUtgNXKlAwMIPeh\nk1gva8/OYYqVuizoszjPnbhh9mOpc50o1ahyNz1Z9NRG1TM8Q3y+2Wl5MpHb8x9E\nHEsTkAz2HimZ2fj3pOju4QewhqV3ytWjzTyFfZ6d56SUMSZ5lpvMkZgXyJ7R6+zS\nx8tq6++W3qIBCG35pmhBIDqWmSM1PmOC8lguYX6AkQKBgQD3qSRFGtPfcAD5l1dF\nvp8e44x/qQ1wg7uUe45dWvF4ycTNbxUKUnoJoQtOfBzTwFdj8DXRIc/OwlXVDnLi\nRLf99MrrijARUjNlgxz/kotZ4ydtU1SNU3k8GWuelI2dHPl5lTv9S4+TWbfy/Ozr\nFbcQ0oolzi5CKgBNkkB9kP/3TQKBgQDlEiBm/rWa3As6l+7ikwRwO21kzEeL/Xkh\nKpkorMHV6OlSR/pabfkHl4gLekZHUMyEYukr2IEPEi1qpUnjC/25Mc/om1M/YuJs\ng95vntOTHX/Dh1lbate/ZFKQmJhlQcfOnvbWpKhZyOkO1afS82I6ewhzfxrY+9Lx\nzty8tvhyaQKBgQDF5Fp9+XzY6jdtOJfcu/+LgAmRLHT3tdtaPww33mZavObLvHoU\ngGjRbuSI9zVVojhyO8vU6u6Q6MoK73uu/3gBrevDH+1euc8lywmN0fwVfCPSAKbs\nMooKEsnishMiOrfBhhSkRg9Yj3Uj7SQmiHh6MbF/metupP8O/NEZRJazdQKBgHz2\nroaBXUDl2ZpVWBRyb3FqefsLFdzgojvdqT/vPq8bKG2ipoi+haQGnkjko4I0Kd3u\nt5UbvwwhtnT/Rpd96yQkcG9MjNV/dFYOekIaOwF+jjx0keK1Ho1ihUgsdraGdCHb\nxnzBxrV0TO+yzqLd8zBD/hBDvrmwZxtS5khs6IxBAoGAb7TwJSUvH/lz4fvvZ/dg\nGGgoWjskDD/JQxJNxogYj5jzLpM5O8sDSRru0AUQbSXKBp9E1ob4Yv+mILPwhAbi\nXqQCExQ7fumKZjXP5BYPePy6B13iGuVfM8woK9v5XzMkbYTBRjTTnmHEQBklc1Hi\nchg9xETdkdIvjSfXBcQLkNU=\n-----END PRIVATE KEY-----\n",
          "client_email":
              "firebase-adminsdk-fbsvc@power-path-c1bb4.iam.gserviceaccount.com",
          "client_id": "111902676270775781023",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url":
              "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url":
              "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40power-path-c1bb4.iam.gserviceaccount.com",
          "universe_domain": "googleapis.com"
        },
      ),
      scopes,
    );

    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}*/

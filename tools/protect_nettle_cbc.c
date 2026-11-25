/* CBC reference for the Twofish and Serpent protected-envelope tests. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <nettle/cbc.h>
#include <nettle/nettle-meta.h>
#include <nettle/version.h>

static const struct nettle_cipher *find_cipher(const char *name)
{
    const struct nettle_cipher *const ciphers[] = {
        &nettle_twofish128, &nettle_twofish192, &nettle_twofish256,
        &nettle_serpent128, &nettle_serpent192, &nettle_serpent256,
    };
    for (size_t i = 0; i < sizeof ciphers / sizeof ciphers[0]; ++i) {
        if (strcmp(ciphers[i]->name, name) == 0)
            return ciphers[i];
    }
    return NULL;
}

static int write_digest(const char *name)
{
    const struct nettle_hash *const methods[] = {
        &nettle_sha1, &nettle_md5, &nettle_md2, &nettle_ripemd160,
    };
    const struct nettle_hash *hash = NULL;
    for (size_t i = 0; i < sizeof methods / sizeof methods[0]; ++i) {
        if (strcmp(methods[i]->name, name) == 0) {
            hash = methods[i];
            break;
        }
    }
    if (hash == NULL)
        return 2;

    uint8_t input[4096], output[32];
    if (hash->digest_size > sizeof output)
        return 2;
    void *context = malloc(hash->context_size);
    if (context == NULL)
        return 2;
    hash->init(context);
    size_t count;
    while ((count = fread(input, 1, sizeof input, stdin)) > 0)
        hash->update(context, count, input);
#if NETTLE_VERSION_MAJOR >= 4
    hash->digest(context, output);
#else
    hash->digest(context, hash->digest_size, output);
#endif
    free(context);
    return ferror(stdin) || fwrite(output, 1, hash->digest_size, stdout) != hash->digest_size ||
           fflush(stdout) == EOF ? 2 : 0;
}

int main(int argc, char **argv)
{
    if (argc == 2 && strcmp(argv[1], "--version") == 0) {
        printf("%d.%d\n", nettle_version_major(), nettle_version_minor());
        return 0;
    }
    if (argc == 3 && strcmp(argv[1], "--digest") == 0)
        return write_digest(argv[2]);
    if (argc != 3 || (strcmp(argv[2], "-e") != 0 && strcmp(argv[2], "-d") != 0))
        return 2;
    const struct nettle_cipher *cipher = find_cipher(argv[1]);
    if (cipher == NULL)
        return 2;

    /* stdio transports the key, the IV and the consecutive full blocks. */
    uint8_t key[32], iv[16], source[16], result[16];
    if (cipher->key_size > sizeof key || cipher->block_size != sizeof iv ||
        fread(key, 1, cipher->key_size, stdin) != cipher->key_size ||
        fread(iv, 1, sizeof iv, stdin) != sizeof iv)
        return 2;
    void *context = malloc(cipher->context_size);
    if (context == NULL)
        return 2;

    int decrypt = strcmp(argv[2], "-d") == 0;
    if (decrypt)
        cipher->set_decrypt_key(context, key);
    else
        cipher->set_encrypt_key(context, key);

    int exit_code = 0;
    size_t count;
    while ((count = fread(source, 1, sizeof source, stdin)) > 0) {
        if (count != sizeof source) {
            exit_code = 2;
            break;
        }
        if (decrypt)
            cbc_decrypt(context, cipher->decrypt, sizeof iv, iv, count, result, source);
        else
            cbc_encrypt(context, cipher->encrypt, sizeof iv, iv, count, result, source);
        if (fwrite(result, 1, count, stdout) != count) {
            exit_code = 2;
            break;
        }
    }
    free(context);
    return ferror(stdin) || fflush(stdout) == EOF ? 2 : exit_code;
}

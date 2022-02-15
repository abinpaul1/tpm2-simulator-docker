# tpm2-emulator

Provides the TPM 2.0 tool software stack with the command line tools and
the TPM 2.0 emulator.

## Docker container availability

```bash
docker build .
docker run -it <image-id>
```

## Inside container : Running the emulator

```bash
tpm_server &
```

If you want to start with a fresh state run it with `-rm` as an option.

Before any TPM command will work you must send it a startup command, with
a real TPM it is apparently the job of the BIOS to do this.

```bash
tpm2_startup --clear
```



## References
- https://github.com/starlab-io/docker-tpm2-emulator
- https://github.com/kgoldman/ibmtss

For latest source tools, check
- https://github.com/tpm2-software/tpm2-tss/releases
- https://github.com/tpm2-software/tpm2-tools/releases
- https://sourceforge.net/projects/ibmswtpm2/

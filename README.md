# credesbois 0.0.1

GPU miner for NEB (Neural Engine Byte, nebhash v2 mainnet) on NVIDIA GPUs (RTX 30 / 40 / 50 series: sm_86, sm_89,
sm_120). Linux x86-64, glibc 2.29 or newer (HiveOS 20.04 bases and newer). Binary release; the source is not public.

## Developer fee: 1 %, declared

- 1 % of the mining work goes to the developer address
  `neb1v05e4h75wv2ah2ajje76ahwr5txc7d7gtzsu7st6gmxewnye6d3sfyv5tj` (worker `credesbois`).
  The other 99 % goes to your address. Your shares are never sent under any other address.
- How it works: about once every 100 minutes, credesbois opens a separate connection to your current pool
  under the developer address and mines on it for about 60 seconds. It stops as soon as the fee reaches 1 %
  of the total work counted by the miner. Your own connection stays open the whole time.
- Every fee window is written to the log: at startup (`FRAIS DE DEVELOPPEMENT : 1 % ...`), when a window starts
  (`frais 1 % (declares) : debut ...`) and when it ends (`frais : fin ... frais cumules 1.00 % du travail`).
- If the pool does not accept the fee connection, the fee is skipped and tried again 10 minutes later. Your
  mining is not interrupted.

## Integrity check (fail-closed)

At startup the miner checks its own binary (a seal computed at build time) and the developer fee address.
If the binary was modified or corrupted, or the fee address was changed, it **refuses to start**: it prints
`VERIFICATION D INTEGRITE ECHOUEE ...` and exits with code 3. The HiveOS run script then waits 5 minutes before
trying again. Reinstall the official package and check its sha256.
The miner also refuses a NEB address with a wrong bech32m checksum, so a typo cannot send your earnings nowhere.

## HiveOS

Flight sheet, custom miner:

| Field | Value |
|---|---|
| Miner name | `credesbois` |
| Installation URL | URL of `credesbois-0.0.1.tar.gz` |
| Hash algorithm | `nebhash` |
| Wallet and worker template | `YOUR_NEB_ADDRESS.%WORKER_NAME%` |
| Pool URL | `stratum+tcp://neb.suprnova.cc:7804` (suprnova) or `neb.ariabrain.com:3370` (AriaPool) |
| Extra config arguments | optional, see below, for example `--backup neb.ariabrain.com:3370` |

Options (Extra config arguments):

- `--backup HOST:PORT`: backup pool. The same address.worker is used, and the protocol is detected from the URL.
  The miner switches to it when the main pool is down (3 failed connections in a row, or no usable job for
  60 s). While on the backup, it checks the main pool every 10 minutes and returns to it as soon as it sends a
  job. The log shows `BASCULE vers secours` / `RETOUR principal`. A second URL in the Pool URL field works too.
- `-d 0,1`: GPUs to use (default: all).
- `--max-live N`: fixed nonce-filter threshold (default: automatic).
- `-v`: verbose log.

Command line:

```sh
./credesbois -u YOUR_NEB_ADDRESS -w rig01 -o stratum+tcp://neb.suprnova.cc:7804 --backup neb.ariabrain.com:3370
./credesbois --bench      # offline benchmark (stop the miner first), about 2 minutes
```

## Notes

- Every share is recomputed by the official C reference implementation before it is sent. A GPU whose results
  differ from the reference is rebuilt, and the process is restarted if the error persists.
- One process drives all GPUs and needs very little CPU. Startup takes under a minute; there is no long self-test.
- Log messages are in French.

## Licenses

credesbois is proprietary software. All rights are reserved, except for the third-party parts listed in
`THIRD_PARTY_NOTICES`:

- the NEB reference code (`pow/ref`, Apache-2.0, see `LICENSE-NEB-Apache-2.0`);
- `neb-datasets.bin` from NEB 1.0.1 (BLAKE3 in `DATASET_HASH`). It contains data derived from the NASA Exoplanet
  Archive (Kepler) and from Astronet-Triage-v2 (TESS, CC BY 4.0).

---

# credesbois 0.0.1 (francais)

Mineur GPU NEB (nebhash v2, mainnet) pour NVIDIA (RTX 30 / 40 / 50). Binaire seul, source non publique.

**Frais de developpement : 1 %, declares.** 1 % du travail va a l adresse du developpeur
`neb1v05e4h75wv2ah2ajje76ahwr5txc7d7gtzsu7st6gmxewnye6d3sfyv5tj` (worker `credesbois`). Les 99 % restants vont a
votre adresse, et vos parts ne sont jamais envoyees sous une autre adresse.

Environ toutes les 100 minutes, une connexion separee au meme pool mine environ 60 s pour le developpeur, puis
s arrete des que les frais atteignent 1 % du travail total. Chaque fenetre de frais est ecrite dans le journal
(debut, fin, pourcentage cumule).

**Verification d integrite.** Au demarrage, le mineur verifie son propre binaire et l adresse de frais. Si le
binaire a ete modifie ou corrompu, ou si l adresse de frais a ete changee, il refuse de demarrer (code 3) et le
dit clairement. Une adresse NEB dont la somme de controle bech32m est fausse est aussi refusee.

**HiveOS.** Meme feuille de vol que ci-dessus. Pool de secours : `--backup HOTE:PORT` dans
"Extra config arguments".

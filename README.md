<p align="center"><img src="https://github.com/user-attachments/assets/7785a8d6-6e28-4892-8958-3daf85414f05" width="80" alt="Bonfÿre knight" /></p>

# Bonfÿre: local service components example

An earlier example combining a small API surface, local identity operations, usage metering, invoicing and CMS records.

**Try the current product direction:** [Request-to-books walkthrough](https://docs.aurekai.work/request-to-books).

## What's in this repository

| File | Use |
|---|---|
| [`setup.sh`](setup.sh) | Inspect setup/build requirements |
| [`run.sh`](run.sh) | Run the original sample workflow |
| [`test.sh`](test.sh) | Run the original example checks |
| [`stop.sh`](stop.sh) | Stop the local example services |

This example was authored in **April 2026** and is retained as a historical runnable-source reference, not a separately supported Bonfÿre release. The canonical engineering repository and its command contracts have evolved since this example was written.

## Run the original example

Read [`setup.sh`](setup.sh) before allowing it to install dependencies or clone source. On a machine where those dependencies are appropriate:

```sh
./setup.sh
./run.sh
```

This demonstrates local service composition, not payment processing or a supported replacement for Stripe, an authorization provider, or managed infrastructure. Invoices, accepted commitments and settled payments are different records.

## Build from the current software

[Bonfÿre source](https://github.com/Nickgonzales76017/bonfyre) · [Aurekai work samples](https://aurekai-work-samples.pages.dev/) · [Guides](https://docs.aurekai.work/)

Current Bonfÿre source is **source-available under its own license**; older sample code retains any separate license that applies to its published version. Inspect each component's terms before redistribution.

## How to use

- Ensure that the [Magic](https://docs.modular.com/max/tutorials/magic) command line tool is installed by following the [Modular Docs](https://docs.modular.com/magic).

```bash
magic shell -e mojo-24-5
mojo miniMNIST.mojo
```

## Performance

```
Loading MNIST data...
Opening MNIST data files...
Magic numbers - Images: 2051 Labels: 2049
Dimensions: 28 x 28
Found 60000 images and 60000 labels
Loading 60000 images...
Data loading complete
First few labels: 5 0 4 1 9
Loaded 60000 images
Initializing network...
Starting training...
Training size: 48000
Validation size: 12000

Epoch 1 / 20
Epoch 1 complete. Validation accuracy: 0.95550000667572021 Time taken: 20.100651606

Epoch 2 / 20
Epoch 2 complete. Validation accuracy: 0.96566665172576904 Time taken: 19.884858411

Epoch 3 / 20
Epoch 3 complete. Validation accuracy: 0.96991664171218872 Time taken: 20.30401599

Epoch 4 / 20
Epoch 4 complete. Validation accuracy: 0.97008335590362549 Time taken: 20.187020280999999

Epoch 5 / 20
Epoch 5 complete. Validation accuracy: 0.97233331203460693 Time taken: 20.371783857

Epoch 6 / 20
Epoch 6 complete. Validation accuracy: 0.97299998998641968 Time taken: 20.389886529999998

Epoch 7 / 20
Epoch 7 complete. Validation accuracy: 0.97600001096725464 Time taken: 20.525772905

Epoch 8 / 20
Epoch 8 complete. Validation accuracy: 0.97633332014083862 Time taken: 20.445676482

Epoch 9 / 20
Epoch 9 complete. Validation accuracy: 0.97775000333786011 Time taken: 20.441106343000001

Epoch 10 / 20
Epoch 10 complete. Validation accuracy: 0.9778333306312561 Time taken: 20.677632752000001

Epoch 11 / 20
Epoch 11 complete. Validation accuracy: 0.9779166579246521 Time taken: 20.582663681

Epoch 12 / 20
Epoch 12 complete. Validation accuracy: 0.97808331251144409 Time taken: 20.747185061

Epoch 13 / 20
Epoch 13 complete. Validation accuracy: 0.97858333587646484 Time taken: 21.618341247

Epoch 14 / 20
Epoch 14 complete. Validation accuracy: 0.97925001382827759 Time taken: 22.368804635

Epoch 15 / 20
Epoch 15 complete. Validation accuracy: 0.97958332300186157 Time taken: 21.811621772999999

Epoch 16 / 20
Epoch 16 complete. Validation accuracy: 0.97983330488204956 Time taken: 21.196523197000001

Epoch 17 / 20
Epoch 17 complete. Validation accuracy: 0.98008334636688232 Time taken: 21.606173892000001

Epoch 18 / 20
Epoch 18 complete. Validation accuracy: 0.98016667366027832 Time taken: 21.751294617999999

Epoch 19 / 20
Epoch 19 complete. Validation accuracy: 0.98041665554046631 Time taken: 21.684000040000001

Epoch 20 / 20
Epoch 20 complete. Validation accuracy: 0.9805833101272583 Time taken: 21.726395978999999

Training complete!
Final validation accuracy: 0.9805833101272583

```

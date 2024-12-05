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
Epoch 1 complete. Validation accuracy: 0.9244999885559082 Time taken: 3.2805267310000001

Epoch 2 / 20
Epoch 2 complete. Validation accuracy: 0.94225001335144043 Time taken: 3.3567499870000002

Epoch 3 / 20
Epoch 3 complete. Validation accuracy: 0.94816666841506958 Time taken: 3.4052891199999999

Epoch 4 / 20
Epoch 4 complete. Validation accuracy: 0.95616668462753296 Time taken: 3.34441517

Epoch 5 / 20
Epoch 5 complete. Validation accuracy: 0.9584166407585144 Time taken: 3.3228434779999998

Epoch 6 / 20
Epoch 6 complete. Validation accuracy: 0.96125000715255737 Time taken: 3.2519564760000002

Epoch 7 / 20
Epoch 7 complete. Validation accuracy: 0.96324998140335083 Time taken: 3.3390046610000002

Epoch 8 / 20
Epoch 8 complete. Validation accuracy: 0.96450001001358032 Time taken: 3.3112622329999999

Epoch 9 / 20
Epoch 9 complete. Validation accuracy: 0.96516668796539307 Time taken: 3.3692055349999999

Epoch 10 / 20
Epoch 10 complete. Validation accuracy: 0.96558332443237305 Time taken: 3.3659106990000001

Epoch 11 / 20
Epoch 11 complete. Validation accuracy: 0.96616667509078979 Time taken: 3.3572180239999998

Epoch 12 / 20
Epoch 12 complete. Validation accuracy: 0.96749997138977051 Time taken: 3.3702589559999998

Epoch 13 / 20
Epoch 13 complete. Validation accuracy: 0.96775001287460327 Time taken: 3.3665469109999999

Epoch 14 / 20
Epoch 14 complete. Validation accuracy: 0.968666672706604 Time taken: 3.3793998379999999

Epoch 15 / 20
Epoch 15 complete. Validation accuracy: 0.96875 Time taken: 3.3892680149999999

Epoch 16 / 20
Epoch 16 complete. Validation accuracy: 0.96925002336502075 Time taken: 3.411076193

Epoch 17 / 20
Epoch 17 complete. Validation accuracy: 0.96991664171218872 Time taken: 3.3336332139999998

Epoch 18 / 20
Epoch 18 complete. Validation accuracy: 0.97008335590362549 Time taken: 3.2961690589999999

Epoch 19 / 20
Epoch 19 complete. Validation accuracy: 0.97025001049041748 Time taken: 3.3854137529999999

Epoch 20 / 20
Epoch 20 complete. Validation accuracy: 0.97041666507720947 Time taken: 3.3831479149999999

Training complete!
Final validation accuracy: 0.97041666507720947

```

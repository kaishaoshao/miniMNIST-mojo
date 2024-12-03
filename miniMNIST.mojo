from memory.unsafe_pointer import UnsafePointer
from math import exp, sqrt, log
from random import random_float64
from utils.index import Index
from memory import memset_zero
from time import time
alias INPUT_SIZE = 784
alias HIDDEN_SIZE = 256
alias OUTPUT_SIZE = 10
alias LEARNING_RATE = 0.001
alias MOMENTUM = 0.9
alias EPOCHS = 20
alias BATCH_SIZE = 64
alias IMAGE_SIZE = 28
alias TRAIN_SPLIT = 0.8
alias PRINT_INTERVAL = 1000
alias RANDON_INT = 223
alias TRAIN_IMG_PATH = "data/train-images.idx3-ubyte"
alias TRAIN_LBL_PATH = "data/train-labels.idx1-ubyte"
alias RAND_MAX = 32767

@value
struct Layer:
    var weights: UnsafePointer[Float32]
    var biases: UnsafePointer[Float32]
    var weight_momentum: UnsafePointer[Float32]
    var bias_momentum: UnsafePointer[Float32]
    var input_size: Int
    var output_size: Int

    fn __init__(inout self, in_size: Int, out_size: Int):
        self.input_size = in_size
        self.output_size = out_size
        var n = in_size * out_size
        self.weights = UnsafePointer[Float32].alloc(n)
        self.biases = UnsafePointer[Float32].alloc(out_size)
        self.weight_momentum = UnsafePointer[Float32].alloc(n)
        self.bias_momentum = UnsafePointer[Float32].alloc(out_size)
        self.init_weights()

    fn init_weights(self):
        var n = self.input_size * self.output_size
        var scale = sqrt(2.0 / Float32(self.input_size + self.output_size))
        for i in range(n):
            self.weights[i] = scale * (
                2.0 * random_float64().cast[DType.float32]() - 1.0
            )
            self.weight_momentum[i] = 0.0

        for i in range(self.output_size):
            self.biases[i] = 0.0
            self.bias_momentum[i] = 0.0

@value
struct Network:
    var hidden: Layer
    var output: Layer

    fn __init__(inout self):
        self.hidden = Layer(INPUT_SIZE, HIDDEN_SIZE)
        self.output = Layer(HIDDEN_SIZE, OUTPUT_SIZE)


@always_inline
fn format(content: List[UInt8]) -> UInt32:
    var number: UInt32 = 0
    # Combine 4 bytes into a 32-bit integer using bitwise operations
    # Left shift by 8 bits each time and merge new byte using OR operator
    for i in range(4):
        var a = content[i].cast[DType.uint32]()
        number = (number << 8) | a
    return number


@always_inline
fn softmax(input: UnsafePointer[Float32], size: Int):
    var max_val = input[0]
    for i in range(1, size):
        if input[i] > max_val:
            max_val = input[i]

    var sum_exp: Float32 = 0.0
    for i in range(size):
        input[i] = exp(input[i] - max_val)
        sum_exp += input[i]

    for i in range(size):
        input[i] = input[i] / sum_exp


@always_inline
fn relu(x: Float32) -> Float32:
    return max(0, x)


@always_inline
fn relu_derivative(x: Float32) -> Float32:
    return 1 if x > 0 else 0


@always_inline
fn forward(
    network: Network,
    input: UnsafePointer[Float32],
    hidden_output: UnsafePointer[Float32],
    final_output: UnsafePointer[Float32],
):
    # Clear output buffers first
    memset_zero(hidden_output.bitcast[UInt8](), HIDDEN_SIZE * 4)
    memset_zero(final_output.bitcast[UInt8](), OUTPUT_SIZE * 4)

    # Hidden layer
    for i in range(HIDDEN_SIZE):
        var sum: Float32 = 0.0
        for j in range(INPUT_SIZE):
            sum += network.hidden.weights[i * INPUT_SIZE + j] * input[j]
        hidden_output[i] = relu(sum + network.hidden.biases[i])

    # Output layer
    for i in range(OUTPUT_SIZE):
        var sum: Float32 = 0.0
        for j in range(HIDDEN_SIZE):
            sum += (
                network.output.weights[i * HIDDEN_SIZE + j] * hidden_output[j]
            )
        final_output[i] = sum + network.output.biases[i]

    softmax(final_output, OUTPUT_SIZE)


@always_inline
fn backward(
    inout network: Network,
    input: UnsafePointer[Float32],
    hidden_output: UnsafePointer[Float32],
    final_output: UnsafePointer[Float32],
    label: Int,
) raises:


    # Allocate and initialize gradients
    var output_gradients = UnsafePointer[Float32].alloc(OUTPUT_SIZE)
    var hidden_gradients = UnsafePointer[Float32].alloc(HIDDEN_SIZE)

    # Initialize gradients to zero
    memset_zero(output_gradients.bitcast[UInt8](), OUTPUT_SIZE * 4)
    memset_zero(hidden_gradients.bitcast[UInt8](), HIDDEN_SIZE * 4)

    # Output layer gradients (softmax derivative)
    for i in range(OUTPUT_SIZE):
        output_gradients[i] = final_output[i]
    output_gradients[label] -= 1.0

    # Hidden layer gradients
    for i in range(HIDDEN_SIZE):
        var sum: Float32 = 0.0
        for j in range(OUTPUT_SIZE):
            sum += (
                network.output.weights[j * HIDDEN_SIZE + i]
                * output_gradients[j]
            )
        hidden_gradients[i] = sum * relu_derivative(hidden_output[i])

    # Update output layer weights and biases
    for i in range(OUTPUT_SIZE):
        for j in range(HIDDEN_SIZE):
            var idx = i * HIDDEN_SIZE + j
            var grad = output_gradients[i] * hidden_output[j]
            # Clip gradients
            grad = min(max(grad, -1.0), 1.0)

            # Update momentum and weights
            network.output.weight_momentum[idx] = (
                MOMENTUM * network.output.weight_momentum[idx]
                - LEARNING_RATE * grad
            )
            network.output.weights[idx] += network.output.weight_momentum[
                idx
            ]

        # Update output biases
        network.output.bias_momentum[i] = (
            MOMENTUM * network.output.bias_momentum[i]
            - LEARNING_RATE * output_gradients[i]
        )
        network.output.biases[i] += network.output.bias_momentum[i]

    # Update hidden layer weights and biases
    for i in range(HIDDEN_SIZE):
        for j in range(INPUT_SIZE):
            var idx = i * INPUT_SIZE + j
            var grad = hidden_gradients[i] * input[j]
            # Clip gradients
            grad = min(max(grad, -1.0), 1.0)

            # Update momentum and weights
            network.hidden.weight_momentum[idx] = (
                MOMENTUM * network.hidden.weight_momentum[idx]
                - LEARNING_RATE * grad
            )
            network.hidden.weights[idx] += network.hidden.weight_momentum[
                idx
            ]

        # Update hidden biases
        network.hidden.bias_momentum[i] = (
            MOMENTUM * network.hidden.bias_momentum[i]
            - LEARNING_RATE * hidden_gradients[i]
        )
        network.hidden.biases[i] += network.hidden.bias_momentum[i]

    # Free allocated memory
    output_gradients.free()
    hidden_gradients.free()


@always_inline
fn train_batch(
    inout network: Network,
    images: UnsafePointer[UInt8],
    labels: UnsafePointer[UInt8],
    batch_size: Int,
):
    # Pre-allocate buffers for the batch
    var input = UnsafePointer[Float32].alloc(INPUT_SIZE)
    var hidden_output = UnsafePointer[Float32].alloc(HIDDEN_SIZE)
    var final_output = UnsafePointer[Float32].alloc(OUTPUT_SIZE)

    try:
        # Process each sample in the batch
        for b in range(batch_size):
            # Clear buffers
            memset_zero(input.bitcast[UInt8](), INPUT_SIZE * 4)
            memset_zero(hidden_output.bitcast[UInt8](), HIDDEN_SIZE * 4)
            memset_zero(final_output.bitcast[UInt8](), OUTPUT_SIZE * 4)

            # Load and normalize input
            @parameter
            for i in range(INPUT_SIZE):
                var idx = b * INPUT_SIZE + i
                input[i] = images[idx].cast[DType.float32]() / 255.0

            # Forward pass
            forward(network, input, hidden_output, final_output)

            # Backward pass
            var label = labels[b].cast[DType.int32]().value
            backward(network, input, hidden_output, final_output, label)

    except:
        print("Error in train_batch")
    finally:
        # Free allocated memory
        input.free()
        hidden_output.free()
        final_output.free()


@always_inline
fn load_mnist_data() raises -> (
    Tuple[UnsafePointer[UInt8], UnsafePointer[UInt8], Int]
):
    try:
        print("Opening MNIST data files...")
        var img_file = open(TRAIN_IMG_PATH, "rb")
        var lbl_file = open(TRAIN_LBL_PATH, "rb")

        # Read image file header
        var magic = format(img_file.read_bytes(4))
        var num_images = format(img_file.read_bytes(4))
        var rows = format(img_file.read_bytes(4))
        var cols = format(img_file.read_bytes(4))

        # Read label file header
        var label_magic = format(lbl_file.read_bytes(4))
        var num_labels = format(lbl_file.read_bytes(4))

        print("Magic numbers - Images:", magic, "Labels:", label_magic)
        print("Dimensions:", rows, "x", cols)
        print("Found", num_images, "images and", num_labels, "labels")

        if num_images != num_labels:
            print("Mismatch between number of images and labels")
            return (
                UnsafePointer[UInt8].alloc(0),
                UnsafePointer[UInt8].alloc(0),
                0,
            )

        print("Loading", num_images, "images...")

        # Allocate memory
        var images = UnsafePointer[UInt8].alloc(int(num_images) * INPUT_SIZE)
        var labels = UnsafePointer[UInt8].alloc(int(num_images))

        # Read image data directly
        var img_bytes = img_file.read_bytes(int(num_images) * INPUT_SIZE)
        for i in range(len(img_bytes)):
            if i < int(num_images) * INPUT_SIZE:
                images[i] = img_bytes[i]

        # Read label data directly
        var label_bytes = lbl_file.read_bytes(int(num_images))
        for i in range(len(label_bytes)):
            if i < int(num_images):
                labels[i] = label_bytes[i]

        print("Data loading complete")
        print(
            "First few labels:",
            labels[0],
            labels[1],
            labels[2],
            labels[3],
            labels[4],
        )
        img_file.close()
        lbl_file.close()
        return (images, labels, int(num_images))

    except:
        print("Error during data loading")
        return (UnsafePointer[UInt8].alloc(0), UnsafePointer[UInt8].alloc(0), 0)


@always_inline
fn evaluate(
    network: Network,
    images: UnsafePointer[UInt8],
    labels: UnsafePointer[UInt8],
    num_images: Int,
) -> Float32:
    var correct = 0

    # Pre-allocate buffers
    var input = UnsafePointer[Float32].alloc(INPUT_SIZE)
    var hidden_output = UnsafePointer[Float32].alloc(HIDDEN_SIZE)
    var final_output = UnsafePointer[Float32].alloc(OUTPUT_SIZE)

    # Initialize buffers
    memset_zero(input.bitcast[UInt8](), INPUT_SIZE * 4)
    memset_zero(hidden_output.bitcast[UInt8](), HIDDEN_SIZE * 4)
    memset_zero(final_output.bitcast[UInt8](), OUTPUT_SIZE * 4)
    for i in range(num_images):
        # Clear input buffer
        memset_zero(input.bitcast[UInt8](), INPUT_SIZE * 4)

        # Normalize input
        @parameter
        for j in range(INPUT_SIZE):
            input[j] = images[i * INPUT_SIZE + j].cast[DType.float32]() / 255.0

        forward(network, input, hidden_output, final_output)

        # Find predicted class
        var max_idx = 0
        var max_val = final_output[0]
        @parameter
        for j in range(1, OUTPUT_SIZE):
            if final_output[j] > max_val:
                max_val = final_output[j]
                max_idx = j
        if max_idx == labels[i].cast[DType.int32]().value:
            correct += 1

    return Float32(correct) / Float32(num_images)


fn main() raises:
    print("Loading MNIST data...")
    (images, labels, num_images) = load_mnist_data()
    if num_images == 0:
        print("Failed to load MNIST data")
        return
    print("Loaded", num_images, "images")

    print("Initializing network...")
    var network = Network()

    # Calculate training and validation split
    var train_size = int(num_images * TRAIN_SPLIT)
    var val_size = num_images - train_size

    print("Starting training...")
    print("Training size:", train_size)
    print("Validation size:", val_size)

    for epoch in range(EPOCHS):
        print("\nEpoch", epoch + 1, "/", EPOCHS)
        var start_time = time.now()
        # Training phase
        for batch_start in range(0, train_size, BATCH_SIZE):
            var current_batch_size = min(BATCH_SIZE, train_size - batch_start)
            train_batch(
                network,
                images.offset(batch_start * INPUT_SIZE),
                labels.offset(batch_start),
                current_batch_size,
            )
            # Print progress every PRINT_INTERVAL batches
            if (batch_start // BATCH_SIZE + 1) % PRINT_INTERVAL == 0:
                var accuracy = evaluate(
                    network,
                    images.offset(train_size * INPUT_SIZE),  # Validation set
                    labels.offset(train_size),
                    val_size,
                )
                print(
                    "Batch",
                    batch_start // BATCH_SIZE + 1,
                    "Validation accuracy:",
                    accuracy,
                )

        # Evaluate on validation set after each epoch
        var epoch_accuracy = evaluate(
            network,
            images.offset(train_size * INPUT_SIZE),
            labels.offset(train_size),
            val_size,
        )
        var end_time = time.now()
        print(
            "Epoch",
            epoch + 1,
            "complete. Validation accuracy:",
            epoch_accuracy,
            "Time taken:",
            (end_time - start_time) / 1000000000.0,
        )

    print("\nTraining complete!")
    var final_accuracy = evaluate(
        network,
        images.offset(train_size * INPUT_SIZE),
        labels.offset(train_size),
        val_size,
    )
    print("Final validation accuracy:", final_accuracy)

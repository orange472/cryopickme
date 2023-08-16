

function net2 = TrainClassificationNet(X_train, Y_train, X_valid, Y_valid, num_epochs)

% Check System Requirements
% Get GPU device information
deviceInfo = gpuDevice;

% Check the GPU compute capability
computeCapability = str2double(deviceInfo.ComputeCapability);
assert(computeCapability > 3.0, 'This example requires a GPU device with compute capability 3.0 or higher.')

%% Data
num_class = 2;
num_trainsamp = size(Y_train, 1);
num_validsamp = size(Y_valid, 1);
num_samples = num_trainsamp + num_validsamp;

%num_class = size(unique([Y_train; Y_valid]), 1);
%num_samples = size([Y_train; Y_valid], 1);
%ratio = [0.9, 0.1, 0];


batch_size = 8;
learning_rate = 0.00005;

train_iter = floor(num_trainsamp / batch_size);

imageSize = [64 64 1];
%imageSize = [46 46 1];
%imageSize = [rbox_scale*2 rbox_scale*2 1];

%X_resize = imresize(X, imageSize(1:2));
%clear X;
X_train = imresize(X_train, imageSize(1:2));
X_valid = imresize(X_valid, imageSize(1:2));

%[X_train, X_valid, X_test, Y_train, Y_valid, Y_test] = SplitTrainValidTest(X_resize, Y, ratio);

%% Define network
layers = [
    imageInputLayer(imageSize)
    
    convolution2dLayer(11, 16,'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(4, 'Stride', 1)
    
    convolution2dLayer(7, 16,'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(4,'Stride', 1)
    
    convolution2dLayer(5, 32,'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride', 1)
    
    convolution2dLayer(3, 64,'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride', 1)
    
    dropoutLayer(0.5)
    
    fullyConnectedLayer(128)
    reluLayer
    
    fullyConnectedLayer(num_class)
    softmaxLayer
    classificationLayer];

%% Training Options
options = trainingOptions('adam', ...
    'MaxEpochs', num_epochs, ...
    'ValidationData', {X_valid, Y_valid}, ...
    'ValidationFrequency', train_iter, ...
    'Verbose', false, ...
    'ExecutionEnvironment','gpu', ...
    'MiniBatchSize', batch_size, ...
    'InitialLearnRate', learning_rate);



%% Train network
net2 = trainNetwork(X_train, Y_train, layers, options);


end
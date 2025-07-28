```mermaid
%%{init: {'theme': 'neutral', 'fontFamily': 'Arial'}}%%
graph TD
    %% Data Loading Section
    A[MNIST Dataset] -->|60,000 images| B(Train DataLoader)
    A -->|10,000 images| C(Test DataLoader)
    B -->|Batch: 64x1x28x28| D[Model Training]
    C -->|Batch: 64x1x28x28| E[Model Evaluation]

    %% Model Architecture
    subgraph CNN[CNN Model Architecture]
        direction TB
        D --> F[Input: 64x1x28x28]
        F --> G[Conv2d: 1→32, kernel=3x3]
        G --> H[ReLU]
        H --> I[MaxPool2d: 2x2]
        I --> J[Conv2d: 32→64, kernel=3x3]
        J --> K[ReLU]
        K --> L[MaxPool2d: 2x2]
        L --> M[Flatten]
        M --> N[Linear: 1600→10]
        N --> O[Output: 64x10]
    end

    %% Training Process
    subgraph Training[Training Loop]
        direction LR
        D --> P[Forward Pass]
        P --> Q[Loss Calculation]
        Q --> R[Backward Pass]
        R --> S[Optimizer Step]
        S -->|Update Weights| G
    end

    %% Evaluation
    E --> T[Calculate Accuracy]
    T --> U[Save Best Model]

    %% Key Processes
    style D fill:#f9f,stroke:#333
    style E fill:#f9f,stroke:#333
    style P fill:#bbf,stroke:#333
    style Q fill:#bbf,stroke:#333
    style R fill:#bbf,stroke:#333
    style T fill:#bfb,stroke:#333
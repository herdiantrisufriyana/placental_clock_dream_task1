import pandas as pd
from joblib import load

def load_and_predict(prefix, extdata, intermediate):
    # Load the scaler and model
    scaler = load(f'{extdata}/{prefix}_scaler.joblib')
    best_model = load(f'{extdata}/{prefix}_best_model.joblib')

    # Load the new dataset for prediction
    X_new = pd.read_csv(f'{intermediate}/{prefix}_set.csv')

    # Standardize the new dataset using the same scaler
    X_new_scaled = scaler.transform(X_new)

    # Make predictions
    predictions = best_model.predict(X_new_scaled)

    # Convert predictions to a DataFrame
    predictions_df = pd.DataFrame(predictions, columns=['prediction'])

    # Save the predicted outcomes to a CSV file
    predictions_path = f'{intermediate}/{prefix}_predictions.csv'
    predictions_df.to_csv(predictions_path, index=False)
    print(f"Predictions saved at {predictions_path}")

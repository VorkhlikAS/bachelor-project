from data_module.utils import get_root_path
import data_module.db as db
import pandas as pd
from sklearn import model_selection
from sklearn import svm, tree
from sklearn.ensemble import RandomForestClassifier
import pickle
import os
from matplotlib import pyplot as plt
import numpy as np


MODELS = {
    "svm":svm.SVC(probability=True),
    "dt":tree.DecisionTreeClassifier(),
    "rf":RandomForestClassifier(n_estimators=50)
          }

def get_user_data():
    pass


def predict(run_id):
    print(f'DEBUG: predicting {run_id}')
    df = db.get_user_data(run_id)
    df = pd.DataFrame(df)
    
    X = df.loc[:, 1:40]

    print(X.head())

    filename = f'model_{run_id}.sav'
    # load the model from disk
    model_path = os.path.join(get_root_path(), "models")
    filepath = os.path.join(model_path, filename)
    if os.path.isfile(filepath):
        loaded_model = pickle.load(open(filepath, 'rb'))
    else:
        filepath = os.path.join(model_path, 'the_model.sav')
        loaded_model = pickle.load(open(filepath, 'rb'))

    y = loaded_model.predict(X)
    res = pd.DataFrame(y)
    print(res.head())
    res = pd.concat([df.loc[:, 0], res], axis=1, keys=['id', 'is_bot'])
    print(f'DEBUG: saving {run_id}')
    filename = f'res_{run_id}.csv'
    data_output_path = os.path.join(get_root_path(), "data_output")
    res.to_csv(os.path.join(data_output_path, filename), header=False, index=False)

    bot_class = np.array(y).astype(float)

    if type(loaded_model) == type(MODELS['dt']):
        probs = loaded_model.predict_proba(X)     
    else: 
        probs = loaded_model.predict_proba(X)[:,1]
    
    print(bot_class)
    print(probs)

    plt.figure(figsize=(15,7))
    if 0 in bot_class: 
        plt.hist(probs[bot_class==0], bins=50, label='Человек' , range=[0.0, 1.0])
    if 1 in bot_class:
        plt.hist(probs[bot_class==1], bins=50, label='Бот', alpha=0.7, color='r', range=[0.0, 1.0])
    plt.xlabel('Уверенность модели', fontsize=25)
    plt.ylabel('Количество', fontsize=25)
    plt.legend(fontsize=15)
    plt.tick_params(axis='both', labelsize=25, pad=5)

    filename = f'plot_{run_id}.png'
    plot_path = os.path.join(get_root_path(), "static", "images")
    plt.savefig(os.path.join(plot_path, filename), bbox_inches='tight')


def train(run_id, model_type):
    print(f'DEBUG: training {run_id}')
    df = db.get_user_data(run_id)
    df = pd.DataFrame(df)

    Y = df.loc[:, 41]
    X = df.loc[:, 1:40]
    test_size = 0.33
    seed = 7

    print(X[X.applymap(lambda x: isinstance(x, str)).any(axis=1)])  # Найти строки, содержащие значения, которые не являются числами

    X_train, X_test, Y_train, Y_test = model_selection.train_test_split(X, Y, test_size=test_size, random_state=seed)
    # # Fit the model on training set
    model = MODELS[model_type]
    try:
        model.fit(X_train, Y_train)
    except Exception as e:
        return str('Загруженные данные не подходят для обучения!')
    
    # save the model to disk
    filename = f'model_{run_id}.sav'
    model_path = os.path.join(get_root_path(), "models")
    pickle.dump(model, open(os.path.join(model_path, filename), 'wb'))
    result = model.score(X_test, Y_test)
    print(f'DEBUG: score: {result}')
    print(f'DEBUG: saving {filename}')

    return 'success'


# if __name__ == "__main__":
#     train(112, 'dt')
#     train(112, 'svm')
#     train(112, 'rf')

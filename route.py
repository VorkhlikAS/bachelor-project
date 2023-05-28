import os
from flask import Flask, render_template, request, redirect, url_for, send_from_directory, jsonify
from data_module.utils import get_root_path
from data_module.vk_parse import get_users_by_file
import data_module.ml as ml
import data_module.db as db
from time import sleep

app = Flask(__name__)

PROJECT_FOLDER = get_root_path()


@app.route('/')
def index():
    runs = db.get_runs()
    initial_run_id = request.args.get('new_run_id')
    initial_run_name = None
    for ln in runs:
        if str(ln[0]) == str(initial_run_id):
            initial_run_name = ln[1]

    return render_template('upload.html', runs=runs, initial_run_name=initial_run_name)


@app.route('/upload/<string:runId>', methods=['POST'])
def upload_csv(runId):
    csv_file = request.files['csv_file']
    if not csv_file:
        return "No file uploaded."
    else:
        data_input_path = os.path.join(get_root_path(), "data_input")
        csv_file.save(os.path.join(data_input_path, csv_file.filename))

        user_data = get_users_by_file(csv_file.filename)

        db.set_status(runId, 2)
        load_id = db.create_load(runId)
        db.load_user_data(runId, load_id, user_data)
        os.remove(os.path.join(data_input_path, csv_file.filename))
        db.write_log('DELETE', 'server: deleting source file')
        return redirect(url_for('index', new_run_id=runId))


@app.route('/create_run', methods=['POST'])
def create_run():
    run_name = request.form['myInput']
    new_run_id = db.create_run(run_name)
    return redirect(url_for('index', new_run_id=new_run_id))


@app.route('/create_model/<string:runId>', methods=['POST'])
def create_model(runId):
    model = request.form['model-type']
    ml.train(runId, model)
    db.set_status(runId, 3)
    db.write_log('CREATE', f'server: creating {model}')
    return redirect(url_for('index', new_run_id=runId))


@app.route('/skip/<string:runId>', methods=['POST'])
def skip(runId):
    db.set_status(runId, 2)
    db.set_status(runId, 3)
    return redirect(url_for('index', new_run_id=runId))


@app.route('/delete/<string:runId>', methods=['POST'])
def delete(runId):
    db.delete_run(runId)
    
    for dir, file in {
        'models':f'model_{runId}.sav',
        'data_output':f'res_{runId}.csv'
                      }.items():
        path = os.path.join(get_root_path(), dir)
        filepath = os.path.join(path, file)
        # Check if file exists
        if os.path.isfile(filepath):
            os.remove(filepath)
        else:
            print(f'DEBUG: {file} doesn\'t exist')
        
    path = os.path.join(get_root_path(), 'static', 'images')
    filepath = os.path.join(path, f'plot_{runId}.png')
    # Check if file exists
    if os.path.isfile(filepath):
        os.remove(filepath)
    else:
        print(f'DEBUG: {filepath} doesn\'t exist')
    
    return redirect(url_for('index'))


@app.route('/upload_test/<string:runId>', methods=['POST'])
def upload_test(runId):
    csv_file = request.files['csv_file']
    if not csv_file:
        return "No file uploaded."
    else:
        db.write_log('INSERT', f'server: loading test')
        data_input_path = os.path.join(get_root_path(), "data_input")
        csv_file.save(os.path.join(data_input_path, csv_file.filename))

        user_data = get_users_by_file(csv_file.filename, test=1)

        db.set_status(runId, 4)
        load_id = db.create_load(runId)
        db.load_user_data(runId, load_id, user_data)
        os.remove(os.path.join(data_input_path, csv_file.filename))
        db.write_log('DELETE', 'server: deleting source file')
        
        ml.predict(runId)
        db.set_status(runId, 5)
        
        return redirect(url_for('index', new_run_id=runId))



@app.route('/run_calculations/<string:runId>', methods=['POST'])
def run_calculations(runId):
    db.set_status(runId, 5)
    sleep(3)
    db.write_log('UPDATE', f'server: running calculations')
    return redirect(url_for('index', new_run_id=runId))


@app.route('/success')
def success():
    return "CSV file uploaded successfully"



@app.route('/download/<string:runId>', methods=['POST'])
def download(runId):
    # Предположим, что файлы находятся в каталоге "uploads" на вашем сервере
    data_output_path = os.path.join(get_root_path(), 'data_output')
    filename = f'res_{runId}.csv'
    # filename = 'test.csv'
    print(f'DEBUG: download res_{runId}.csv')
    return send_from_directory(directory=data_output_path, 
                               filename=filename, 
                               as_attachment=True)


if __name__ == '__main__':
    app.run(debug=False, host='0.0.0.0', port=80)

const buttons = document.querySelectorAll('button');
buttons.forEach(button => button.disabled = true);
const runLinks = document.querySelectorAll('.run-link');
  const header = document.getElementById('header');
  const contentContainer = document.getElementById('content-container');
  const uploadButton = document.getElementById('upload-button');
  const createModelButton = document.getElementById('create-model-button');
  const uploadTestButton = document.getElementById('upload-test-button');
  const infoButton = document.getElementById('info-button');

  infoButton.addEventListener('click', () => {
        const runName = header.getAttribute("data-run-name");
        const runStatus = header.getAttribute("data-run-status");
        const runId = header.getAttribute("data-run-id");
        buttons.forEach(button => button.className = 'bn3639 bn39');
        infoButton.className = 'bn3639-chosen bn39-chosen';
        var timestamp = new Date().getTime();
        contentContainer.innerHTML = `
              <div style="display:flex;">
                <div class="col-md-1"> 
                  <p>
                    Название:   ${runName}<br>
                  Id расчета:   ${runId}<br>
                      Статус:   ${runStatus}
                  </p>
                  <form id="delete-run" action="/delete/${runId}" method="POST">
                    <button type="submit" class="bndelete bnd" onClick="loader()">Удалить расчет</button>
                  </form>
                  ${runStatus === 'Результаты расчета готовы к выгрузке (5).' ?
                    `<form id="download-file" action="/download/${runId}" method="POST">
                      <button type="submit" class="file-download file-download--upload">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-cloud-download" viewBox="0 0 16 16">
                        <path d="M4.406 1.342A5.53 5.53 0 0 1 8 0c2.69 0 4.923 2 5.166 4.579C14.758 4.804 16 6.137 16 7.773 16 9.569 14.502 11 12.687 11H10a.5.5 0 0 1 0-1h2.688C13.979 10 15 8.988 15 7.773c0-1.216-1.02-2.228-2.313-2.228h-.5v-.5C12.188 2.825 10.328 1 8 1a4.53 4.53 0 0 0-2.941 1.1c-.757.652-1.153 1.438-1.153 2.055v.448l-.445.049C2.064 4.805 1 5.952 1 7.318 1 8.785 2.23 10 3.781 10H6a.5.5 0 0 1 0 1H3.781C1.708 11 0 9.366 0 7.318c0-1.763 1.266-3.223 2.942-3.593.143-.863.698-1.723 1.464-2.383z"/>
                        <path d="M7.646 15.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 14.293V5.5a.5.5 0 0 0-1 0v8.793l-2.146-2.147a.5.5 0 0 0-.708.708l3 3z"/>
                      </svg> &nbsp;Скачать результаты</button>
                    </form>`: ``
                  }
                </div>
                ${runStatus === 'Результаты расчета готовы к выгрузке (5).' ? 
                  `<div class="col-md-2"> 
                  <img class="plot" src="/static/images/plot_${runId}.png?timestamp=${timestamp}"></img>
                </div>`:``
                }
              </div>
              `;
    });

  uploadButton.addEventListener('click', () => {
        // show upload form
          const runId = header.getAttribute("data-run-id");
        buttons.forEach(button => button.className = 'bn3639 bn39');
        uploadButton.className = 'bn3639-chosen bn39-chosen';
        contentContainer.innerHTML = `
            <p>Загрузить файл для обучения модели:</p>
            <form class="upload-form" action="/upload/${runId}" method="POST" enctype="multipart/form-data">
              <div class="file file--upload">
                <label for="input-file">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-cloud-upload" viewBox="0 0 16 16">
                  <path fill-rule="evenodd" d="M4.406 1.342A5.53 5.53 0 0 1 8 0c2.69 0 4.923 2 5.166 4.579C14.758 4.804 16 6.137 16 7.773 16 9.569 14.502 11 12.687 11H10a.5.5 0 0 1 0-1h2.688C13.979 10 15 8.988 15 7.773c0-1.216-1.02-2.228-2.313-2.228h-.5v-.5C12.188 2.825 10.328 1 8 1a4.53 4.53 0 0 0-2.941 1.1c-.757.652-1.153 1.438-1.153 2.055v.448l-.445.049C2.064 4.805 1 5.952 1 7.318 1 8.785 2.23 10 3.781 10H6a.5.5 0 0 1 0 1H3.781C1.708 11 0 9.366 0 7.318c0-1.763 1.266-3.223 2.942-3.593.143-.863.698-1.723 1.464-2.383z"/>
                  <path fill-rule="evenodd" d="M7.646 4.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V14.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3z"/>
                </svg> &nbsp;Выбрать файл
                </label>
                <input id="input-file" type="file" name="csv_file" />
              <button type="submit" class="bn3637 bn38" onClick="loader()"> Загрузить </button>
              </div>
            </form>
            <form id="skip-run" action="/skip/${runId}" method="POST">
              <button type="submit" class="bn3637 bn38">Использовать встроенную модель</button>
            </form>
        `;
  });

  uploadTestButton.addEventListener('click', () => {
        // show upload form
          const runId = header.getAttribute("data-run-id");
        buttons.forEach(button => button.className = 'bn3639 bn39');
        uploadTestButton.className = 'bn3639-chosen bn39-chosen';
        contentContainer.innerHTML = `
            <p>Загрузить файл для расчета по выбранной модели:</p>
            <form class="upload-form" action="/upload_test/${runId}" method="POST" enctype="multipart/form-data">
              <div class="file file--upload">
                <label for="input-file">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-cloud-upload" viewBox="0 0 16 16">
                  <path fill-rule="evenodd" d="M4.406 1.342A5.53 5.53 0 0 1 8 0c2.69 0 4.923 2 5.166 4.579C14.758 4.804 16 6.137 16 7.773 16 9.569 14.502 11 12.687 11H10a.5.5 0 0 1 0-1h2.688C13.979 10 15 8.988 15 7.773c0-1.216-1.02-2.228-2.313-2.228h-.5v-.5C12.188 2.825 10.328 1 8 1a4.53 4.53 0 0 0-2.941 1.1c-.757.652-1.153 1.438-1.153 2.055v.448l-.445.049C2.064 4.805 1 5.952 1 7.318 1 8.785 2.23 10 3.781 10H6a.5.5 0 0 1 0 1H3.781C1.708 11 0 9.366 0 7.318c0-1.763 1.266-3.223 2.942-3.593.143-.863.698-1.723 1.464-2.383z"/>
                  <path fill-rule="evenodd" d="M7.646 4.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1-.708.708L8.5 5.707V14.5a.5.5 0 0 1-1 0V5.707L5.354 7.854a.5.5 0 1 1-.708-.708l3-3z"/>
                </svg> &nbsp;Выбрать файл
                </label>
                <input id="input-file" type="file" name="csv_file" />
              <button type="submit" class="bn3637 bn38" onClick="loader()"> Загрузить </button>
              </div>
            </form>
        `;
  });

  createModelButton.addEventListener('click', () => {
      // show create model form
      const runId = header.getAttribute("data-run-id");
      buttons.forEach(button => button.className = 'bn3639 bn39');
      createModelButton.className = 'bn3639-chosen bn39-chosen';
      const formHTML = `
        <form id="model-form" action="/create_model/${runId}" method="POST">
          <div class="radio-group">
            <input type="radio" name="model-type" id="tree" value="dt" required>
            <label for="tree">Решающее дерево</label>
          </div>
          <div class="radio-group">
            <input type="radio" name="model-type" id="forest" value="rf" required>
            <label for="forest">Случайный лес</label>
          </div>
          <div class="radio-group">
            <input type="radio" name="model-type" id="svm" value="svm" required>
            <label for="svm">Метод опорных векторов</label>
          </div>
          <button type="submit" class="bn3637 bn38">Обучить</button>
        </form>
      `;
      contentContainer.innerHTML = formHTML;
  });

  runLinks.forEach(link => {
      link.addEventListener('click', event => {
        buttons.forEach(button => button.disabled = false);
        const runName = event.target.textContent;
        const runId = event.target.getAttribute('data-run-id');
        const runStatus = event.target.getAttribute('data-run-status');
        const previously_chosen = document.querySelectorAll('.run-link-chosen');
        const tmp = document.querySelectorAll('.run-link');
        buttons.forEach(button => button.className = 'bn3639 bn39');
        infoButton.className = 'bn3639-chosen bn39-chosen';
        previously_chosen.forEach(link => link.className='run-link');
        event.target.className = 'run-link-chosen';
        // Set the data-run-id attribute
        header.setAttribute('data-run-id', runId);

        // Set the data-run-name attribute
        header.setAttribute('data-run-name', runName);

        // Set the data-run-status attribute
        header.setAttribute('data-run-status', runStatus);

        header.textContent = `${runName}`;
        // header.innerHTML = `<h1 id="header" data-run-id="runId" data-run-name="${runName}" data-run-status="${runStatus}" style="font-size: 32px;">${runName}</h1>`;
        var timestamp = new Date().getTime();
        contentContainer.innerHTML = `
              <div style="display:flex;">
                <div class="col-md-1"> 
                  <p>
                    Название:   ${runName}<br>
                  Id расчета:   ${runId}<br>
                      Статус:   ${runStatus}
                  </p>
                  <form id="delete-run" action="/delete/${runId}" method="POST">
                    <button type="submit" class="bndelete bnd" onClick="loader()">Удалить расчет</button>
                  </form>
                  ${runStatus === 'Результаты расчета готовы к выгрузке (5).' ?
                    `<form id="download-file" action="/download/${runId}" method="POST">
                      <button type="submit" class="file-download file-download--upload">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-cloud-download" viewBox="0 0 16 16">
                        <path d="M4.406 1.342A5.53 5.53 0 0 1 8 0c2.69 0 4.923 2 5.166 4.579C14.758 4.804 16 6.137 16 7.773 16 9.569 14.502 11 12.687 11H10a.5.5 0 0 1 0-1h2.688C13.979 10 15 8.988 15 7.773c0-1.216-1.02-2.228-2.313-2.228h-.5v-.5C12.188 2.825 10.328 1 8 1a4.53 4.53 0 0 0-2.941 1.1c-.757.652-1.153 1.438-1.153 2.055v.448l-.445.049C2.064 4.805 1 5.952 1 7.318 1 8.785 2.23 10 3.781 10H6a.5.5 0 0 1 0 1H3.781C1.708 11 0 9.366 0 7.318c0-1.763 1.266-3.223 2.942-3.593.143-.863.698-1.723 1.464-2.383z"/>
                        <path d="M7.646 15.854a.5.5 0 0 0 .708 0l3-3a.5.5 0 0 0-.708-.708L8.5 14.293V5.5a.5.5 0 0 0-1 0v8.793l-2.146-2.147a.5.5 0 0 0-.708.708l3 3z"/>
                      </svg> &nbsp;Скачать результаты</button>
                    </form>`: ``
                  }
                </div>
                ${runStatus === 'Результаты расчета готовы к выгрузке (5).' ? 
                  `<div class="col-md-2"> 
                  <img class="plot" src="/static/images/plot_${runId}.png?timestamp=${timestamp}"></img>
                </div>`:``
                }
              </div>
              `;

        
        // enable buttons based on run status
        if (runStatus === 'Расчет создан (1).') {
            uploadButton.disabled = false;
            createModelButton.disabled = true;
            uploadTestButton.disabled = true;
        } else if (runStatus === 'Для расчета загружены учебные данные (2).') {
            uploadButton.disabled = true;
            createModelButton.disabled = false;
            uploadTestButton.disabled = true;
        } else if (runStatus === 'Для расчета обучены модели (3).') {
            uploadButton.disabled = true;
            createModelButton.disabled = true;
            uploadTestButton.disabled = false;
        } else if (runStatus === 'Для расчета загружены тестировочные данные (4).') {
            uploadButton.disabled = true;
            createModelButton.disabled = true;
            uploadTestButton.disabled = true;
        }  else if (runStatus === 'Результаты расчета готовы к выгрузке (5).') {
          uploadButton.disabled = true;
          createModelButton.disabled = true;
          uploadTestButton.disabled = false;
      } 
      });
    });

  function checkInput() {
  var input = document.getElementById("myInput");
  var button = document.getElementById("myButton");
  if (input.value.length > 0) {
    button.disabled = false;
  } else {
    button.disabled = true;
  }
}

    function loadPage(initialRunName) {
        // Code to set up run list item click handlers as before

        // If an initial run name is specified, click on the corresponding run list item
        // loader();
        if (initialRunName) {
            const runLinks = document.querySelectorAll('.run-link');
            for (let i = 0; i < runLinks.length; i++) {
                if (runLinks[i].textContent === initialRunName) {
                    runLinks[i].click();
                    break;
                }
            }
        }
    }

    function loader() {
      const loader = document.getElementById('loader');
      if (loader.style.opacity === "1") {
        loader.style.opacity = "0";
      } else {
        loader.style.opacity = "1";
      }
    }


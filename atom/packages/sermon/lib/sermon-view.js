'use babel';

import fs from 'fs';
import path from 'path';
import {Emitter} from 'atom';

import SermonSettings from './sermon-settings';


export default class SermonView {

  constructor(serializedState) {

    this.emitter = new Emitter();

    this.element = document.createElement('div');
    this.element.classList.add('sermon');

    this.element.innerHTML = fs.readFileSync(path.join(__dirname, './sermon-view.html'));

    this.port = '';
    this.ports = this.element.querySelector('#sermon-port');
    this.baudrate = this.element.querySelector('#sermon-baudrate');
    this.format = this.element.querySelector('#sermon-format');
    this.timestamp = this.element.querySelector('#sermon-timestamp');
    this.color = this.element.querySelector('#sermon-color');

    this.buttonConnect = this.element.querySelector('#sermon-connect');
    this.buttonConnect.addEventListener('click', () => {
        this.emitter.emit('connect');
    });

    this.buttonCancel = this.element.querySelector('#sermon-cancel');
    this.buttonCancel.addEventListener('click', () => {
        this.emitter.emit('cancel');
    });
  }

  serialize() {}

  destroy() {
    this.element.remove();
  }

  getElement() {
    return this.element;
  }

  onConnect(callback) {
    this.emitter.on('connect', callback);
  }

  onCancel(callback) {
    this.emitter.on('cancel', callback);
  }

  setPorts(ports) {

    var html = '';

    for(var p in ports) {
      var selected = '';

      if(this.port == ports[p].device) {
          selected = ' selected';
      }

      html = html + '<option value="' + ports[p].device + '"' + selected + '>' +
        ports[p].device + ' (' + ports[p].description + ')</option>';
    }
    this.ports.innerHTML = html;
  }

  fromSettings(settings) {

    this.port = settings.port;
    this.ports.value = settings.port;
    this.baudrate.value = settings.baudrate;
    this.format.value = settings.format;

    this.timestamp.checked = settings.timestamp;
    this.color.checked = settings.color;
  }

  toSettings() {

    var settings = new SermonSettings();

    this.port = this.ports.value;
    settings.port = this.ports.value;
    settings.baudrate = this.baudrate.value;
    settings.format = this.format.value;

    settings.timestamp = this.timestamp.checked;
    settings.color = this.color.checked;

    return settings;
  }
}

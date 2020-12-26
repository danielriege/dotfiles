'use babel';

import path from 'path';
import SermonView from './sermon-view';

import { BufferedProcess } from 'atom';
import { Disposable } from 'atom';
import { CompositeDisposable } from 'atom';

import SermonSettings from './sermon-settings';


export default {

  sermonView: null,
  modalPanel: null,
  subscriptions: null,
  terminal: null,
  terminalView: null,

  activate(state) {

    require('atom-package-deps').install('sermon', true)
      .then(function() {
        console.log('sermon dependencies installed');
      });

    this.sermonSettings = new SermonSettings();
    this.sermonView = new SermonView(state.sermonViewState);
    this.sermonView.fromSettings(this.sermonSettings);

    this.modalPanel = atom.workspace.addModalPanel({
      item: this.sermonView.getElement(),
      visible: false
    });

    this.subscriptions = new CompositeDisposable();

    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'sermon:toggle': () => this.toggle()
    }));

    this.sermonView.onConnect(
        () => this.connect()
    );

    this.sermonView.onCancel(
        () => this.toggle()
    );
  },

  consumeRunInTerminal(terminal)
  {
    this.terminal = terminal;

    return new Disposable(() => {
      this.terminal = null;
    });
  },

  deactivate() {
    this.modalPanel.destroy();
    this.subscriptions.dispose();
    this.sermonView.destroy();
  },

  serialize() {
    return {
      sermonViewState: this.sermonView.serialize()
    };
  },

  toggle() {
    console.log('sermon toggled');

    if(this.modalPanel.isVisible()) {
      this.modalPanel.hide();
    }
    else {
      this.detectSerialPorts();
      this.sermonSettings.read();
      this.sermonView.fromSettings(this.sermonSettings);
      this.modalPanel.show();
      this.sermonView.buttonConnect.focus();
    }
  },

  detectSerialPorts() {

    console.log('sermon detecting serial ports');

    var result = '';

    var res_dir = path.join(
      __dirname, path.join('..', 'resources')
    );

    var script = 'pysermon.py';
    var cmd = path.join(res_dir, script);

    var proc = new BufferedProcess({
        command: cmd,
        args: ['--listjson'],
        stdout: (data) => {
            result += data;
        },
        exit: (code) => {
            if(code) {
                atom.notifications.addError('Failed to detect ports');
            }
            console.log('sermon detected ports: ' + result);
            this.sermonView.setPorts(JSON.parse(result).ports);
        }
    });

    proc.onWillThrowError((err) => {
      err.handle();
      atom.notifications.addError('Failed to detect ports');
    });
  },

  connect() {

    console.log('sermon starting in terminal');

    this.modalPanel.hide();

    if(this.terminalView) {
      console.log('sermon terminating running instance first');
      this.terminalView.statusBar.activeTerminal = this.terminalView;
      this.terminalView.statusBar.destroyActiveTerm();
      this.terminalView = null;
    }

    var res_dir = path.join(
      __dirname, path.join('..', 'resources')
    );

    this.sermonSettings = this.sermonView.toSettings();
    this.sermonSettings.write();

    if(this.sermonSettings.port == '') {
      atom.notifications.addError('There was no port given!',
        {detail: 'Please connect your device and select a port.'});
      return;
    }

    var script = 'pysermon.py';
    var flags = ' -w --persist';

    if(this.sermonSettings.color) {
        flags = flags + ' -c';
    }

    if(this.sermonSettings.timestamp) {
        flags = flags + ' -t';
    }

    var cmd = path.join(res_dir, script) +
      ' -p ' + this.sermonSettings.port +
      ' -b ' + this.sermonSettings.baudrate +
      ' -f ' + this.sermonSettings.format +
      flags;

    console.log('sermon executing: ' + cmd);

    if(this.terminal) {
      this.terminal.run([cmd]);

      var views = this.terminal.getTerminalViews();
      this.terminalView = views[views.length - 1];
    }
    else {
      atom.notifications.addError('Serial monitor failed',
        {detail: 'Terminal service was not found! Consider installing the termination package.'})
    }
  }
};

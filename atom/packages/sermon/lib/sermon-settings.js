'use babel';

import fs from 'fs';
import path from 'path';


export default class SermonSettings {

    constructor() {

      this.port = '';
      this.baudrate = 9600;
      this.format = 'raw';

      this.timestamp = true;
      this.color = true;
    }

    getCurrentProjectDir() {

      var editor = atom.workspace.getActiveTextEditor();

      if(editor) {
          var f = editor.getPath();

          if(f) {
              var p = atom.project.relativizePath(f);

              if(p) {
                  return p[0];
              }
          }
      }

      return null;
    }

    getSettingsFileName() {

      var p = this.getCurrentProjectDir();

      if(p) {
          return path.join(p, "sermon_settings.json");
      }

      return null;
    }

    read() {

      var fname = this.getSettingsFileName();

      if(fname && fs.existsSync(fname)) {

        console.log('sermon reading settings from: ' + fname);

        var json = JSON.parse(fs.readFileSync(fname));

        this.port = json.port;
        this.baudrate = json.baudrate;
        this.format = json.format;

        this.timestamp = json.timestamp;
        this.color = json.color;
      }
    }

    write() {

      var fname = this.getSettingsFileName();

      if(fname) {
          console.log('sermon writing settings to: ' + fname);
          fs.writeFileSync(fname, JSON.stringify(this));
      }
      else {
          atom.notifications.addError("sermon failed to save settings");
      }
    }

    dump() {

      console.log(
          ';port=' + this.port +
          ';baudrate=' + this.baudrate +
          ';format=' + this.format +
          ';timestamp=' + this.timestamp +
          ';color=' + this.color
      );
    }
}

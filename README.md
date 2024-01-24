# EPFViewer

A [Godot](https://godotengine.org/) 4.x project to render EPFs w/
PALs from NexusTK/Baram DATs

![EPFViewer](./epfviewer.gif)

## Setup / Usage

* Import the `project.godot` file in Godot 4.x and Run the
application (F5)

* If you don't have NexusTK in a predictable location, the program
won't start (see next step)

* `config.json.template` is copied to `config.json` (if
`config.json` does not exist) - Fill out this config to point to
your system's NexusTK/Baram directories

* Re-run the application (F5) and EPFViewer should hopefully launch

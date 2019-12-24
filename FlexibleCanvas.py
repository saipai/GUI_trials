# https://stackoverflow.com/questions/54581915/how-do-you-get-a-tkinter-widget-to-size-with-canvas-display-window

import math
import sys
if sys.version_info[0] < 3:
  from Tkinter import Tk, Button, Frame, Canvas, Scrollbar
  import Tkconstants
else:
  from tkinter import Tk, Button, Frame, Canvas, Scrollbar
  import tkinter.constants as Tkconstants

from matplotlib import pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import pprint

frame = None
canvas = None


def FrameHeight(event):
    canvas_height = event.height
    canvas_width = event.width
    print(canvas_height)
    # canvas.itemconfig(cwid, height=canvas_height)
    canvas.itemconfig(cwid, width=canvas_width)
    print(frame.winfo_height())
    print('FIGINFO')
    print(figure.get_size_inches())
    print(figure.dpi)
    size = figure.get_size_inches() * figure.dpi  # size in pixels
    print(size)
    if size[1] < frame.winfo_height():
        canvas.itemconfig(cwid, height=canvas_height)
    if size[1] > 500:
        canvas.itemconfig(cwid, height=canvas_height)

    # wi, hi = [i * figure.dpi for i in figure.get_size_inches()]


def printBboxes(label=""):
  global canvas, mplCanvas, interior, interior_id, cwid
  print("  "+label,
    "canvas.bbox:", canvas.bbox(Tkconstants.ALL),
    "mplCanvas.bbox:", mplCanvas.bbox(Tkconstants.ALL))

def addScrollingFigure(figure, frame):
  global canvas, mplCanvas, interior, interior_id, cwid
  # set up a canvas with scrollbars
  canvas = Canvas(frame)
  canvas.grid(row=1, column=1, sticky=Tkconstants.NSEW)

  # xScrollbar = Scrollbar(frame, orient=Tkconstants.HORIZONTAL)
  yScrollbar = Scrollbar(frame)

  # xScrollbar.grid(row=2, column=1, sticky=Tkconstants.EW)
  yScrollbar.grid(row=1, column=2, sticky=Tkconstants.NS)

  # canvas.config(xscrollcommand=xScrollbar.set)
  # xScrollbar.config(command=canvas.xview)
  canvas.config(yscrollcommand=yScrollbar.set)
  yScrollbar.config(command=canvas.yview)

  # plug in the figure
  figAgg = FigureCanvasTkAgg(figure, canvas)
  mplCanvas = figAgg.get_tk_widget()
  #mplCanvas.grid(sticky=Tkconstants.NSEW)

  # and connect figure with scrolling region
  cwid = canvas.create_window(0, 0, window=mplCanvas, anchor=Tkconstants.NW)
  printBboxes("Init")
  canvas.config(scrollregion=canvas.bbox(Tkconstants.ALL),width=200,height=200)
  canvas.bind('<Configure>', FrameHeight)

def changeSize(figure, factor):
  global canvas, mplCanvas, interior, interior_id, frame, cwid
  oldSize = figure.get_size_inches()
  print("old size is", oldSize)
  figure.set_size_inches([factor * s for s in oldSize])
  wi,hi = [i*figure.dpi for i in figure.get_size_inches()]
  print("new size is", figure.get_size_inches())
  print("new size pixels: ", wi,hi)
  mplCanvas.config(height=hi) ; printBboxes("A")
  #mplCanvas.grid(sticky=Tkconstants.NSEW)
  canvas.itemconfigure(cwid, height=hi) ; printBboxes("B")
  canvas.config(scrollregion=canvas.bbox(Tkconstants.ALL),width=200,height=200)
  figure.canvas.draw() ; printBboxes("C")
  print()

if __name__ == "__main__":
  root = Tk()
  root.rowconfigure(1, weight=1)
  root.columnconfigure(1, weight=1)

  frame = Frame(root)
  frame.grid(column=1, row=1, sticky=Tkconstants.NSEW)
  frame.rowconfigure(1, weight=1)
  frame.columnconfigure(1, weight=1)

  figure = plt.figure(dpi=100, figsize=(4, 5))
  a = figure.add_subplot(311)
  b = figure.add_subplot(312)
  c = figure.add_subplot(313)
  a.plot(range(10), [math.sin(x) for x in range(10)])
  b.plot(range(10), [math.sin(x) for x in range(10)])
  c.plot(range(10), [math.sin(x) for x in range(10)])

  addScrollingFigure(figure, frame)

  buttonFrame = Frame(root)
  buttonFrame.grid(row=1, column=2, sticky=Tkconstants.NS)
  biggerButton = Button(buttonFrame, text="larger",
                        command=lambda : changeSize(figure, 1.5))
  biggerButton.grid(column=1, row=1)
  smallerButton = Button(buttonFrame, text="smaller",
                         command=lambda : changeSize(figure, .5))
  smallerButton.grid(column=1, row=2)

  root.mainloop()

"""
  interior = Frame(canvas) #Frame(mplCanvas) #cannot
  interior_id = canvas.create_window(0, 0, window=interior)#, anchor=Tkconstants.NW)
  canvas.config(scrollregion=canvas.bbox("all"),width=200,height=200)
  canvas.itemconfigure(interior_id, width=canvas.winfo_width())

  interior_id = canvas.create_window(0, 0, window=interior)#, anchor=Tkconstants.NW)
  canvas.config(scrollregion=canvas.bbox("all"),width=200,height=200)
  canvas.itemconfigure(interior_id, width=canvas.winfo_width())
"""
#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy2 Experiment Builder (v1.83.04), Thu Jul 20 21:31:31 2017
If you publish work using this script please cite the relevant PsychoPy publications
  Peirce, JW (2007) PsychoPy - Psychophysics software in Python. Journal of Neuroscience Methods, 162(1-2), 8-13.
  Peirce, JW (2009) Generating stimuli for neuroscience using PsychoPy. Frontiers in Neuroinformatics, 2:10. doi: 10.3389/neuro.11.010.2008
"""

from __future__ import division  # so that 1/3=0.333 instead of 1/3=0
from psychopy import locale_setup, visual, core, data, event, logging, sound, gui
from psychopy.constants import *  # things like STARTED, FINISHED
import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import sin, cos, tan, log, log10, pi, average, sqrt, std, deg2rad, rad2deg, linspace, asarray
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys # to get file system encoding

# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__)).decode(sys.getfilesystemencoding())
os.chdir(_thisDir)

# Store info about the experiment session
expName = u'recog'  # from the Builder filename that created this script
expInfo = {u'session': u'001', u'participant': u''}
dlg = gui.DlgFromDict(dictionary=expInfo, title=expName)
if dlg.OK == False: core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + os.path.join('..','raw-behavioral','s%s','%s%s%s') %(expInfo['participant'], expInfo['participant'], expName, expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath=u'/Users/rhdz/workspace/eetemp/experiment-scripts/recog-only.psyexp',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
#save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(size=(2560, 1440), fullscr=True, screen=0, allowGUI=False, allowStencil=False,
    monitor=u'testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True,
    units='cm')
# store frame rate of monitor if we can measure it successfully
expInfo['frameRate']=win.getActualFrameRate()
if expInfo['frameRate']!=None:
    frameDur = 1.0/round(expInfo['frameRate'])
else:
    frameDur = 1.0/60.0 # couldn't get a reliable measure so guess

# Initialize components for Routine "setPaths"
setPathsClock = core.Clock()
import yaml
from psychopy import parallel, logging, visual
from math import ceil
import re #this is how we get grep
import numpy

config = yaml.load(open(os.path.join('..', 'config.yml'), 'r'))
directories = config['directories']
stimDir = directories['stimuli']
rawDataDir = directories['raw-behavioral-dir']

global pulse_sent
pulse_sent = False
global pulse_terminated
pulse_terminated = False

global pulse_start_time
pulse_start_time = 0

#setup parallel port for sending EEG trigger codes
port_present = 0 # set to 0 for testing when parallel port isn't around
if port_present:
    port = parallel.PParallelLinux(address='/dev/parport0') 
    # start with a tidy port
    port.setData(0)
    global pulse_sent
    pulse_sent = False
    global pulse_terminated
    pulse_terminated = False

# Setup timing using frame rate
itemFirstDur = 0.7
thinkCueDur= 1.7
frame_rate = win.getActualFrameRate()

itemFirstDurFrames = ceil(itemFirstDur * frame_rate)
thinkCueDurFrames = ceil(thinkCueDur * frame_rate)
thisExp.addData("itemFirst_numFrames", itemFirstDurFrames) 
thisExp.addData("thinkCue_numFrames", thinkCueDurFrames) 

# setup function for sending triggers
# based on: 
# https://discourse.psychopy.org/t/word-by-word-sentence-presentation-with-parallel-port-output/1707/8
# https://discourse.psychopy.org/t/execute-code-at-a-time-offset-in-a-loop-in-builder/938
def portCleanup():
    print("port cleanup")
    # code from: https://discourse.psychopy.org/t/word-by-word-sentence-presentation-with-parallel-port-output/1707/8

    # tidy any that may have not been terminated properly:
    if port_present:
        port.setData(0) 

    global pulse_sent
    pulse_sent = False

    global pulse_terminated
    pulse_terminated = False

def sendTrigger(cond):
    # send the trigger code
    if not pulse_sent and not pulse_terminated:
        if port_present:
            win.callOnFlip(port.setData, cond)

        print("sending trigger")

        global pulse_start_time
        pulse_start_time = t #t is set to 0 at the start of each routine (know from looking at coder view)

        thisExp.addData(("pulse_t_for_" + str(cond)), pulse_start_time) 
        
        global pulse_sent
        pulse_sent = True
        
        global pulse_terminated
        pulse_terminated = False

    # re-set and start listening again
    if pulse_sent and not pulse_terminated:
        cur_time = t
        elapsed_time = cur_time - pulse_start_time
        print("checking to see if enough time has elasped to reset the port")
        print("t: " + str(t))
        print("pulse_start_time: "+str(pulse_start_time))
        print("elapsed_time: "+str(elapsed_time))

        if elapsed_time >= 0.010:

            print("enough time has elapsed; resetting port to 0")
            if port_present:
                port.setData(0)

            global pulse_terminated
            pulse_terminated = True



# Initialize components for Routine "recogInstructions"
recogInstructionsClock = core.Clock()

recogInstrText = visual.TextStim(win=win, ori=0, name='recogInstrText',
    text='You will now complete the memory task. \n\nAs we practiced earlier, you will see studied and new objects and make a REMEMBER, FAMILIAR, NEW memory judgment. Then, you will try to remember which question the item was paired with.\n\nDo you have any questions before we begin?',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)

# Initialize components for Routine "beginBlock"
beginBlockClock = core.Clock()
begin_0 = visual.TextStim(win=win, ori=0, name='begin_0',
    text='We are almost ready to start, but there a few things to do first to prepare yourself...',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=0.0)
begin_1 = visual.TextStim(win=win, ori=0, name='begin_1',
    text='Take a moment to get comfortable.',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)
blinks = visual.TextStim(win=win, ori=0, name='blinks',
    text='Please take a few moments to blink your eyes.',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-2.0)
begin_2 = visual.TextStim(win=win, ori=0, name='begin_2',
    text='Get ready...the next set of trials will begin soon!',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-3.0)
begin_fix = visual.TextStim(win=win, ori=0, name='begin_fix',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-4.0)

# Initialize components for Routine "Break"
BreakClock = core.Clock()

subj_break_screen = visual.TextStim(win=win, ori=0, name='subj_break_screen',
    text='Take a short break. \n\nPress 1 when you are ready to continue!',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)

# Initialize components for Routine "variableITI"
variableITIClock = core.Clock()

text = visual.TextStim(win=win, ori=0, name='text',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)

# Initialize components for Routine "itemRecog"
itemRecogClock = core.Clock()

image_first_presentation = visual.ImageStim(win=win, name='image_first_presentation',
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
think_cue = visual.TextStim(win=win, ori=0, name='think_cue',
    text='T',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-2.0)
image_for_item_recog = visual.ImageStim(win=win, name='image_for_item_recog',
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-3.0)
item_recog_scale = visual.TextStim(win=win, ori=0, name='item_recog_scale',
    text='default text',    font='Arial',
    pos=[0, -11], height=1, wrapWidth=25,
    color='white', colorSpace='rgb', opacity=1,
    depth=-4.0)
fix_cross_itemRecog1 = visual.TextStim(win=win, ori=0, name='fix_cross_itemRecog1',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-6.0)
fix_cross_itemRecog2 = visual.TextStim(win=win, ori=0, name='fix_cross_itemRecog2',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-7.0)

# Initialize components for Routine "itemConf"
itemConfClock = core.Clock()

image_for_item_conf = visual.ImageStim(win=win, name='image_for_item_conf',
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
conf_resp_question = visual.TextStim(win=win, ori=0, name='conf_resp_question',
    text='default text',    font='Arial',
    pos=[0, -9], height=1, wrapWidth=35,
    color='white', colorSpace='rgb', opacity=1,
    depth=-2.0)
conf_resp_scale = visual.TextStim(win=win, ori=0, name='conf_resp_scale',
    text='1=highly  2=moderately  3=somewhat  4=not at all',    font='Arial',
    pos=[0, -11], height=1, wrapWidth=35,
    color='white', colorSpace='rgb', opacity=1,
    depth=-3.0)
fix_cross_itemConf = visual.TextStim(win=win, ori=0, name='fix_cross_itemConf',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-5.0)

# Initialize components for Routine "sourceJudgment"
sourceJudgmentClock = core.Clock()

image_for_source_judgment = visual.ImageStim(win=win, name='image_for_source_judgment',
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
source_scale = visual.TextStim(win=win, ori=0, name='source_scale',
    text='default text',    font='Arial',
    pos=[0, -11], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-2.0)
fix_cross_sourceJudgment = visual.TextStim(win=win, ori=0, name='fix_cross_sourceJudgment',
    text='+',    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-4.0)

# Initialize components for Routine "betweenBreak"
betweenBreakClock = core.Clock()

breakText = visual.TextStim(win=win, ori=0, name='breakText',
    text='Take a chance to rest and blink.\n\nLet the experimenter know when you are ready for the next set of trials.',    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)
mouse = event.Mouse(win=win)
x, y = [None, None]

# Initialize components for Routine "endScreen"
endScreenClock = core.Clock()

endScreenText = visual.TextStim(win=win, ori=0, name='endScreenText',
    text='You are now finished with this part of the task. \n\nPlease let the experimenter know. ',    font='Arial',
    pos=[0, 0], height=1.5, wrapWidth=None,
    color='white', colorSpace='rgb', opacity=1,
    depth=-1.0)

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

#------Prepare to start Routine "setPaths"-------
t = 0
setPathsClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
#if not pulse_sent:
#    cond = 255
#    thisExp.addData(("expt_onset_" + str(cond)), core.getTime()) 
#    sendTrigger(cond, pulse_terminated, pulse_sent)

# keep track of which components have finished
setPathsComponents = []
for thisComponent in setPathsComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "setPaths"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = setPathsClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in setPathsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "setPaths"-------
for thisComponent in setPathsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)

# the Routine "setPaths" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

#------Prepare to start Routine "recogInstructions"-------
t = 0
recogInstructionsClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
print("routine starting: recogInstructions")
portCleanup()

recogInstrResp = event.BuilderKeyResponse()  # create an object of type KeyResponse
recogInstrResp.status = NOT_STARTED
# keep track of which components have finished
recogInstructionsComponents = []
recogInstructionsComponents.append(recogInstrText)
recogInstructionsComponents.append(recogInstrResp)
for thisComponent in recogInstructionsComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "recogInstructions"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = recogInstructionsClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    # code from: https://discourse.psychopy.org/t/word-by-word-sentence-presentation-with-parallel-port-output/1707/8
    if recogInstrText.status==STARTED:
        cond = 3
        sendTrigger(cond)
    
    
    # *recogInstrText* updates
    if t >= 0.0 and recogInstrText.status == NOT_STARTED:
        # keep track of start time/frame for later
        recogInstrText.tStart = t  # underestimates by a little under one frame
        recogInstrText.frameNStart = frameN  # exact frame index
        recogInstrText.setAutoDraw(True)
    
    # *recogInstrResp* updates
    if t >= 0.0 and recogInstrResp.status == NOT_STARTED:
        # keep track of start time/frame for later
        recogInstrResp.tStart = t  # underestimates by a little under one frame
        recogInstrResp.frameNStart = frameN  # exact frame index
        recogInstrResp.status = STARTED
        # keyboard checking is just starting
        win.callOnFlip(recogInstrResp.clock.reset)  # t=0 on next screen flip
        event.clearEvents(eventType='keyboard')
    if recogInstrResp.status == STARTED:
        theseKeys = event.getKeys(keyList=['space'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            recogInstrResp.keys = theseKeys[-1]  # just the last key pressed
            recogInstrResp.rt = recogInstrResp.clock.getTime()
            # a response ends the routine
            continueRoutine = False
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in recogInstructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "recogInstructions"-------
for thisComponent in recogInstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
if recogInstrText.status==FINISHED:
    cond = 4
    sendTrigger(cond)

print("routine complete: recogInstructions")

# check responses
if recogInstrResp.keys in ['', [], None]:  # No response was made
   recogInstrResp.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('recogInstrResp.keys',recogInstrResp.keys)
if recogInstrResp.keys != None:  # we had a response
    thisExp.addData('recogInstrResp.rt', recogInstrResp.rt)
thisExp.nextEntry()
# the Routine "recogInstructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
blockLoop = data.TrialHandler(nReps=1, method='sequential', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions('eeg-block-ids.csv'),
    seed=None, name='blockLoop')
thisExp.addLoop(blockLoop)  # add the loop to the experiment
thisBlockLoop = blockLoop.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb=thisBlockLoop.rgb)
if thisBlockLoop != None:
    for paramName in thisBlockLoop.keys():
        exec(paramName + '= thisBlockLoop.' + paramName)

for thisBlockLoop in blockLoop:
    currentLoop = blockLoop
    # abbreviate parameter names if possible (e.g. rgb = thisBlockLoop.rgb)
    if thisBlockLoop != None:
        for paramName in thisBlockLoop.keys():
            exec(paramName + '= thisBlockLoop.' + paramName)
    
    #------Prepare to start Routine "beginBlock"-------
    t = 0
    beginBlockClock.reset()  # clock 
    frameN = -1
    routineTimer.add(23.000000)
    # update component parameters for each repeat
    # keep track of which components have finished
    beginBlockComponents = []
    beginBlockComponents.append(begin_0)
    beginBlockComponents.append(begin_1)
    beginBlockComponents.append(blinks)
    beginBlockComponents.append(begin_2)
    beginBlockComponents.append(begin_fix)
    for thisComponent in beginBlockComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "beginBlock"-------
    continueRoutine = True
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = beginBlockClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *begin_0* updates
        if t >= 0.0 and begin_0.status == NOT_STARTED:
            # keep track of start time/frame for later
            begin_0.tStart = t  # underestimates by a little under one frame
            begin_0.frameNStart = frameN  # exact frame index
            begin_0.setAutoDraw(True)
        if begin_0.status == STARTED and t >= (0.0 + (4.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            begin_0.setAutoDraw(False)
        
        # *begin_1* updates
        if t >= 4.0 and begin_1.status == NOT_STARTED:
            # keep track of start time/frame for later
            begin_1.tStart = t  # underestimates by a little under one frame
            begin_1.frameNStart = frameN  # exact frame index
            begin_1.setAutoDraw(True)
        if begin_1.status == STARTED and t >= (4.0 + (6.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            begin_1.setAutoDraw(False)
        
        # *blinks* updates
        if t >= 10.0 and blinks.status == NOT_STARTED:
            # keep track of start time/frame for later
            blinks.tStart = t  # underestimates by a little under one frame
            blinks.frameNStart = frameN  # exact frame index
            blinks.setAutoDraw(True)
        if blinks.status == STARTED and t >= (10.0 + (5.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            blinks.setAutoDraw(False)
        
        # *begin_2* updates
        if t >= 15.0 and begin_2.status == NOT_STARTED:
            # keep track of start time/frame for later
            begin_2.tStart = t  # underestimates by a little under one frame
            begin_2.frameNStart = frameN  # exact frame index
            begin_2.setAutoDraw(True)
        if begin_2.status == STARTED and t >= (15.0 + (5.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            begin_2.setAutoDraw(False)
        
        # *begin_fix* updates
        if t >= 20.0 and begin_fix.status == NOT_STARTED:
            # keep track of start time/frame for later
            begin_fix.tStart = t  # underestimates by a little under one frame
            begin_fix.frameNStart = frameN  # exact frame index
            begin_fix.setAutoDraw(True)
        if begin_fix.status == STARTED and t >= (20.0 + (3.0-win.monitorFramePeriod*0.75)): #most of one frame period left
            begin_fix.setAutoDraw(False)
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in beginBlockComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "beginBlock"-------
    for thisComponent in beginBlockComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # set up handler to look after randomisation of conditions etc
    responseLoop = data.TrialHandler(nReps=1, method='sequential', 
        extraInfo=expInfo, originPath=-1,
        trialList=data.importConditions(os.path.join('..', 'raw-behavioral', 's'+expInfo['participant'],'eeg_recog_'+str(blockNum)+'.csv')),
        seed=None, name='responseLoop')
    thisExp.addLoop(responseLoop)  # add the loop to the experiment
    thisResponseLoop = responseLoop.trialList[0]  # so we can initialise stimuli with some values
    # abbreviate parameter names if possible (e.g. rgb=thisResponseLoop.rgb)
    if thisResponseLoop != None:
        for paramName in thisResponseLoop.keys():
            exec(paramName + '= thisResponseLoop.' + paramName)
    
    for thisResponseLoop in responseLoop:
        currentLoop = responseLoop
        # abbreviate parameter names if possible (e.g. rgb = thisResponseLoop.rgb)
        if thisResponseLoop != None:
            for paramName in thisResponseLoop.keys():
                exec(paramName + '= thisResponseLoop.' + paramName)
        
        #------Prepare to start Routine "Break"-------
        t = 0
        BreakClock.reset()  # clock 
        frameN = -1
        # update component parameters for each repeat
        
        subj_break_resp = event.BuilderKeyResponse()  # create an object of type KeyResponse
        subj_break_resp.status = NOT_STARTED
        # keep track of which components have finished
        BreakComponents = []
        BreakComponents.append(subj_break_screen)
        BreakComponents.append(subj_break_resp)
        for thisComponent in BreakComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "Break"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = BreakClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # based on https://groups.google.com/forum/#!topic/psychopy-users/gvSkCZa2ceE
            if responseLoop.thisTrialN not in [15,30]:
                continueRoutine=False
            
            # *subj_break_screen* updates
            if t >= 0.0 and subj_break_screen.status == NOT_STARTED:
                # keep track of start time/frame for later
                subj_break_screen.tStart = t  # underestimates by a little under one frame
                subj_break_screen.frameNStart = frameN  # exact frame index
                subj_break_screen.setAutoDraw(True)
            
            # *subj_break_resp* updates
            if t >= 0.0 and subj_break_resp.status == NOT_STARTED:
                # keep track of start time/frame for later
                subj_break_resp.tStart = t  # underestimates by a little under one frame
                subj_break_resp.frameNStart = frameN  # exact frame index
                subj_break_resp.status = STARTED
                # keyboard checking is just starting
                win.callOnFlip(subj_break_resp.clock.reset)  # t=0 on next screen flip
                event.clearEvents(eventType='keyboard')
            if subj_break_resp.status == STARTED:
                theseKeys = event.getKeys(keyList=['1', 'num_1'])
                
                # check for quit:
                if "escape" in theseKeys:
                    endExpNow = True
                if len(theseKeys) > 0:  # at least one key was pressed
                    subj_break_resp.keys.extend(theseKeys)  # storing all keys
                    subj_break_resp.rt.append(subj_break_resp.clock.getTime())
                    # a response ends the routine
                    continueRoutine = False
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in BreakComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "Break"-------
        for thisComponent in BreakComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        
        # check responses
        if subj_break_resp.keys in ['', [], None]:  # No response was made
           subj_break_resp.keys=None
        # store data for responseLoop (TrialHandler)
        responseLoop.addData('subj_break_resp.keys',subj_break_resp.keys)
        if subj_break_resp.keys != None:  # we had a response
            responseLoop.addData('subj_break_resp.rt', subj_break_resp.rt)
        # the Routine "Break" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        #------Prepare to start Routine "variableITI"-------
        t = 0
        variableITIClock.reset()  # clock 
        frameN = -1
        # update component parameters for each repeat
        print("routine starting: variableITI")
        
        # Start counting dropped frames again b/c we care about timing
        # based on: http://www.psychopy.org/general/timing/detectingFrameDrops.html
        win.recordFrameIntervals = True
        
        # based on https://groups.google.com/forum/#!topic/psychopy-users/PqbP5cNu7Vc
        fixDuration = 2
        fixDurationFrames = ceil(fixDuration * frame_rate)
        
        portCleanup()
        # keep track of which components have finished
        variableITIComponents = []
        variableITIComponents.append(text)
        for thisComponent in variableITIComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "variableITI"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = variableITIClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            if not pulse_sent:
                if text.status==STARTED:
                    cond = 40
                    thisExp.addData(("ITI_onset_" + str(cond)), core.getTime()) 
            
                sendTrigger(cond)
            
            
            # *text* updates
            if frameN >= 0 and text.status == NOT_STARTED:
                # keep track of start time/frame for later
                text.tStart = t  # underestimates by a little under one frame
                text.frameNStart = frameN  # exact frame index
                text.setAutoDraw(True)
            if text.status == STARTED and frameN >= (text.frameNStart + fixDurationFrames):
                text.setAutoDraw(False)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in variableITIComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "variableITI"-------
        for thisComponent in variableITIComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        thisExp.addData("ITI_duration_sec", fixDuration) 
        thisExp.addData("ITI_duration_frames", fixDurationFrames)
        thisExp.addData("ITI_nDroppedFrames", win.nDroppedFrames)
        #thisExp.addData("ITI_frameIntervals", win.frameIntervals) # this spits out too much data, but could be used when script testing
        
        if not pulse_sent:
            if text.status==FINISHED:
                cond = 41
                thisExp.addData(("ITI_offset_" + str(cond)), core.getTime()) 
            sendTrigger(cond)
        
        print("routine complete: variableITI")
        # the Routine "variableITI" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        #------Prepare to start Routine "itemRecog"-------
        t = 0
        itemRecogClock.reset()  # clock 
        frameN = -1
        # update component parameters for each repeat
        print("routine starting: itemRecog")
        
        portCleanup()
        image_first_presentation.setImage(os.path.join(stimDir,stim + '.png'))
        image_for_item_recog.setImage(os.path.join(stimDir,stim + '.png'))
        item_recog_scale.setText(objRecScale)
        item_recog_resp = event.BuilderKeyResponse()  # create an object of type KeyResponse
        item_recog_resp.status = NOT_STARTED
        # keep track of which components have finished
        itemRecogComponents = []
        itemRecogComponents.append(image_first_presentation)
        itemRecogComponents.append(think_cue)
        itemRecogComponents.append(image_for_item_recog)
        itemRecogComponents.append(item_recog_scale)
        itemRecogComponents.append(item_recog_resp)
        itemRecogComponents.append(fix_cross_itemRecog1)
        itemRecogComponents.append(fix_cross_itemRecog2)
        for thisComponent in itemRecogComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "itemRecog"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = itemRecogClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            # vary which code is sent based on which component is on the screen
            if not pulse_sent:
                if image_first_presentation.status==STARTED:
                    cond = 10
                    thisExp.addData(("image_first_onset_" + str(cond)), core.getTime()) 
                elif think_cue.status==STARTED:
                    cond = 11
                    thisExp.addData(("think_cue_onset_" + str(cond)), core.getTime())
                elif image_for_item_recog.status==STARTED:
                    cond = 12
                    thisExp.addData(("image_second_onset_" + str(cond)), core.getTime())
                # when try to send trigger here, nothing gets sent
                #elif len(item_recog_resp.keys)>0:
                #    cond = 111
                #    thisExp.addData(("item_recog_resp_" + str(cond)), core.getTime()) 
            
                sendTrigger(cond)
            
            
            # *image_first_presentation* updates
            if frameN >= text.status==FINISHED and image_first_presentation.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_first_presentation.tStart = t  # underestimates by a little under one frame
                image_first_presentation.frameNStart = frameN  # exact frame index
                image_first_presentation.setAutoDraw(True)
            if image_first_presentation.status == STARTED and frameN >= (image_first_presentation.frameNStart + itemFirstDurFrames):
                image_first_presentation.setAutoDraw(False)
            
            # *think_cue* updates
            if frameN >= image_first_presentation.status==FINISHED and think_cue.status == NOT_STARTED:
                # keep track of start time/frame for later
                think_cue.tStart = t  # underestimates by a little under one frame
                think_cue.frameNStart = frameN  # exact frame index
                think_cue.setAutoDraw(True)
            if think_cue.status == STARTED and frameN >= (think_cue.frameNStart + thinkCueDurFrames):
                think_cue.setAutoDraw(False)
            
            # *image_for_item_recog* updates
            if frameN >= think_cue.status==FINISHED and image_for_item_recog.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_for_item_recog.tStart = t  # underestimates by a little under one frame
                image_for_item_recog.frameNStart = frameN  # exact frame index
                image_for_item_recog.setAutoDraw(True)
            
            # *item_recog_scale* updates
            if frameN >= think_cue.status==FINISHED and item_recog_scale.status == NOT_STARTED:
                # keep track of start time/frame for later
                item_recog_scale.tStart = t  # underestimates by a little under one frame
                item_recog_scale.frameNStart = frameN  # exact frame index
                item_recog_scale.setAutoDraw(True)
            
            # *item_recog_resp* updates
            if frameN >= think_cue.status==FINISHED and item_recog_resp.status == NOT_STARTED:
                # keep track of start time/frame for later
                item_recog_resp.tStart = t  # underestimates by a little under one frame
                item_recog_resp.frameNStart = frameN  # exact frame index
                item_recog_resp.status = STARTED
                # keyboard checking is just starting
                win.callOnFlip(item_recog_resp.clock.reset)  # t=0 on next screen flip
                event.clearEvents(eventType='keyboard')
            if item_recog_resp.status == STARTED:
                theseKeys = event.getKeys(keyList=['1', '2', '3', 'num_1', 'num_2', 'num_3'])
                
                # check for quit:
                if "escape" in theseKeys:
                    endExpNow = True
                if len(theseKeys) > 0:  # at least one key was pressed
                    item_recog_resp.keys.extend(theseKeys)  # storing all keys
                    item_recog_resp.rt.append(item_recog_resp.clock.getTime())
                    # a response ends the routine
                    continueRoutine = False
            
            # *fix_cross_itemRecog1* updates
            if t >= 0 and fix_cross_itemRecog1.status == NOT_STARTED:
                # keep track of start time/frame for later
                fix_cross_itemRecog1.tStart = t  # underestimates by a little under one frame
                fix_cross_itemRecog1.frameNStart = frameN  # exact frame index
                fix_cross_itemRecog1.setAutoDraw(True)
            if fix_cross_itemRecog1.status == STARTED and frameN >= (fix_cross_itemRecog1.frameNStart + itemFirstDurFrames):
                fix_cross_itemRecog1.setAutoDraw(False)
            
            # *fix_cross_itemRecog2* updates
            if frameN >= think_cue.status==FINISHED and fix_cross_itemRecog2.status == NOT_STARTED:
                # keep track of start time/frame for later
                fix_cross_itemRecog2.tStart = t  # underestimates by a little under one frame
                fix_cross_itemRecog2.frameNStart = frameN  # exact frame index
                fix_cross_itemRecog2.setAutoDraw(True)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in itemRecogComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "itemRecog"-------
        for thisComponent in itemRecogComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        thisExp.addData("item_nDroppedFrames", win.nDroppedFrames)
        
        if not pulse_sent:
            if len(item_recog_resp.keys)>0:
                cond = 111
                thisExp.addData(("item_recog_resp_" + str(cond)), core.getTime()) 
            sendTrigger(cond)
        
        print("routine complete: itemRecog")
        # check responses
        if item_recog_resp.keys in ['', [], None]:  # No response was made
           item_recog_resp.keys=None
        # store data for responseLoop (TrialHandler)
        responseLoop.addData('item_recog_resp.keys',item_recog_resp.keys)
        if item_recog_resp.keys != None:  # we had a response
            responseLoop.addData('item_recog_resp.rt', item_recog_resp.rt)
        # the Routine "itemRecog" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        #------Prepare to start Routine "itemConf"-------
        t = 0
        itemConfClock.reset()  # clock 
        frameN = -1
        # update component parameters for each repeat
        print("routine starting: itemConf")
        
        portCleanup() 
        
        #no longer need to record dropped frames b/c not looking at EEG for these responses
        win.recordFrameIntervals = False
        
        # handle when subjects use number pad to respond
        if re.match('num_', item_recog_resp.keys[0]):
            resp_num = re.search('num_([123])', item_recog_resp.keys[0]).group(1)
            resp = int(resp_num)
        else:
            resp = int(item_recog_resp.keys[0])
        
        # convert response columns from numpy.int64 to int
        rem_resp = numpy.asscalar(rememberResp)
        fam_resp = numpy.asscalar(familiarResp)
        new_resp = numpy.asscalar(newResp)
        
        if numpy.equal(resp, rem_resp):
            objConfScale = 'How confident are you that you REMEMBER the item?'
        elif numpy.equal(resp, fam_resp):
            objConfScale = 'How confident are you that the item is FAMILIAR?'
        elif numpy.equal(resp, new_resp):
            objConfScale = 'How confident are you that the item is NEW?'
        image_for_item_conf.setImage(os.path.join(stimDir,stim + '.png'))
        conf_resp_question.setText(objConfScale)
        item_conf_response = event.BuilderKeyResponse()  # create an object of type KeyResponse
        item_conf_response.status = NOT_STARTED
        # keep track of which components have finished
        itemConfComponents = []
        itemConfComponents.append(image_for_item_conf)
        itemConfComponents.append(conf_resp_question)
        itemConfComponents.append(conf_resp_scale)
        itemConfComponents.append(item_conf_response)
        itemConfComponents.append(fix_cross_itemConf)
        for thisComponent in itemConfComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "itemConf"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = itemConfClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            
            # *image_for_item_conf* updates
            if t >= 0.0 and image_for_item_conf.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_for_item_conf.tStart = t  # underestimates by a little under one frame
                image_for_item_conf.frameNStart = frameN  # exact frame index
                image_for_item_conf.setAutoDraw(True)
            
            # *conf_resp_question* updates
            if t >= 0.0 and conf_resp_question.status == NOT_STARTED:
                # keep track of start time/frame for later
                conf_resp_question.tStart = t  # underestimates by a little under one frame
                conf_resp_question.frameNStart = frameN  # exact frame index
                conf_resp_question.setAutoDraw(True)
            
            # *conf_resp_scale* updates
            if t >= 0.0 and conf_resp_scale.status == NOT_STARTED:
                # keep track of start time/frame for later
                conf_resp_scale.tStart = t  # underestimates by a little under one frame
                conf_resp_scale.frameNStart = frameN  # exact frame index
                conf_resp_scale.setAutoDraw(True)
            
            # *item_conf_response* updates
            if t >= 0.0 and item_conf_response.status == NOT_STARTED:
                # keep track of start time/frame for later
                item_conf_response.tStart = t  # underestimates by a little under one frame
                item_conf_response.frameNStart = frameN  # exact frame index
                item_conf_response.status = STARTED
                # keyboard checking is just starting
                win.callOnFlip(item_conf_response.clock.reset)  # t=0 on next screen flip
                event.clearEvents(eventType='keyboard')
            if item_conf_response.status == STARTED:
                theseKeys = event.getKeys(keyList=['1', '2', '3', '4', 'num_1', 'num_2', 'num_3', 'num_4'])
                
                # check for quit:
                if "escape" in theseKeys:
                    endExpNow = True
                if len(theseKeys) > 0:  # at least one key was pressed
                    item_conf_response.keys.extend(theseKeys)  # storing all keys
                    item_conf_response.rt.append(item_conf_response.clock.getTime())
                    # a response ends the routine
                    continueRoutine = False
            
            # *fix_cross_itemConf* updates
            if t >= 0.0 and fix_cross_itemConf.status == NOT_STARTED:
                # keep track of start time/frame for later
                fix_cross_itemConf.tStart = t  # underestimates by a little under one frame
                fix_cross_itemConf.frameNStart = frameN  # exact frame index
                fix_cross_itemConf.setAutoDraw(True)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in itemConfComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "itemConf"-------
        for thisComponent in itemConfComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        if not pulse_sent:
            if len(item_conf_response.keys)>0:
                cond = 121
                thisExp.addData(("item_conf_resp_" + str(cond)), core.getTime()) 
            sendTrigger(cond)
        
        print("routine complete: itemConf")
        # check responses
        if item_conf_response.keys in ['', [], None]:  # No response was made
           item_conf_response.keys=None
        # store data for responseLoop (TrialHandler)
        responseLoop.addData('item_conf_response.keys',item_conf_response.keys)
        if item_conf_response.keys != None:  # we had a response
            responseLoop.addData('item_conf_response.rt', item_conf_response.rt)
        # the Routine "itemConf" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        
        #------Prepare to start Routine "sourceJudgment"-------
        t = 0
        sourceJudgmentClock.reset()  # clock 
        frameN = -1
        # update component parameters for each repeat
        print("routine starting: sourceJudgement")
        
        portCleanup()
        image_for_source_judgment.setImage(os.path.join(stimDir,stim + '.png'))
        source_scale.setText('What question did you answer earlier about this item?\n1 - %s\n2 - %s\n3 - %s\n4 - %s' %(q1,q2,q3,q4))
        source_response = event.BuilderKeyResponse()  # create an object of type KeyResponse
        source_response.status = NOT_STARTED
        # keep track of which components have finished
        sourceJudgmentComponents = []
        sourceJudgmentComponents.append(image_for_source_judgment)
        sourceJudgmentComponents.append(source_scale)
        sourceJudgmentComponents.append(source_response)
        sourceJudgmentComponents.append(fix_cross_sourceJudgment)
        for thisComponent in sourceJudgmentComponents:
            if hasattr(thisComponent, 'status'):
                thisComponent.status = NOT_STARTED
        
        #-------Start Routine "sourceJudgment"-------
        continueRoutine = True
        while continueRoutine:
            # get current time
            t = sourceJudgmentClock.getTime()
            frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
            # update/draw components on each frame
            
            
            # *image_for_source_judgment* updates
            if t >= 0.0 and image_for_source_judgment.status == NOT_STARTED:
                # keep track of start time/frame for later
                image_for_source_judgment.tStart = t  # underestimates by a little under one frame
                image_for_source_judgment.frameNStart = frameN  # exact frame index
                image_for_source_judgment.setAutoDraw(True)
            
            # *source_scale* updates
            if t >= 0.0 and source_scale.status == NOT_STARTED:
                # keep track of start time/frame for later
                source_scale.tStart = t  # underestimates by a little under one frame
                source_scale.frameNStart = frameN  # exact frame index
                source_scale.setAutoDraw(True)
            
            # *source_response* updates
            if t >= 0.0 and source_response.status == NOT_STARTED:
                # keep track of start time/frame for later
                source_response.tStart = t  # underestimates by a little under one frame
                source_response.frameNStart = frameN  # exact frame index
                source_response.status = STARTED
                # keyboard checking is just starting
                win.callOnFlip(source_response.clock.reset)  # t=0 on next screen flip
                event.clearEvents(eventType='keyboard')
            if source_response.status == STARTED:
                theseKeys = event.getKeys(keyList=['1', '2', '3', '4', 'num_1', 'num_2', 'num_3', 'num_4'])
                
                # check for quit:
                if "escape" in theseKeys:
                    endExpNow = True
                if len(theseKeys) > 0:  # at least one key was pressed
                    source_response.keys.extend(theseKeys)  # storing all keys
                    source_response.rt.append(source_response.clock.getTime())
                    # a response ends the routine
                    continueRoutine = False
            
            # *fix_cross_sourceJudgment* updates
            if t >= 0.0 and fix_cross_sourceJudgment.status == NOT_STARTED:
                # keep track of start time/frame for later
                fix_cross_sourceJudgment.tStart = t  # underestimates by a little under one frame
                fix_cross_sourceJudgment.frameNStart = frameN  # exact frame index
                fix_cross_sourceJudgment.setAutoDraw(True)
            
            # check if all components have finished
            if not continueRoutine:  # a component has requested a forced-end of Routine
                break
            continueRoutine = False  # will revert to True if at least one component still running
            for thisComponent in sourceJudgmentComponents:
                if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                    continueRoutine = True
                    break  # at least one component has not yet finished
            
            # check for quit (the Esc key)
            if endExpNow or event.getKeys(keyList=["escape"]):
                core.quit()
            
            # refresh the screen
            if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
                win.flip()
        
        #-------Ending Routine "sourceJudgment"-------
        for thisComponent in sourceJudgmentComponents:
            if hasattr(thisComponent, "setAutoDraw"):
                thisComponent.setAutoDraw(False)
        if not pulse_sent:
            if len(source_response.keys)>0:
                cond = 131
                thisExp.addData(("source_resp_" + str(cond)), core.getTime()) 
            sendTrigger(cond)
        
        print("routine complete: sourceJudgement")
        
        # check responses
        if source_response.keys in ['', [], None]:  # No response was made
           source_response.keys=None
        # store data for responseLoop (TrialHandler)
        responseLoop.addData('source_response.keys',source_response.keys)
        if source_response.keys != None:  # we had a response
            responseLoop.addData('source_response.rt', source_response.rt)
        # the Routine "sourceJudgment" was not non-slip safe, so reset the non-slip timer
        routineTimer.reset()
        thisExp.nextEntry()
        
    # completed 1 repeats of 'responseLoop'
    
    
    #------Prepare to start Routine "betweenBreak"-------
    t = 0
    betweenBreakClock.reset()  # clock 
    frameN = -1
    # update component parameters for each repeat
    portCleanup()
    # setup some python lists for storing info about the mouse
    # keep track of which components have finished
    betweenBreakComponents = []
    betweenBreakComponents.append(breakText)
    betweenBreakComponents.append(mouse)
    for thisComponent in betweenBreakComponents:
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    
    #-------Start Routine "betweenBreak"-------
    continueRoutine = True
    while continueRoutine:
        # get current time
        t = betweenBreakClock.getTime()
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        if not pulse_sent:
            if breakText.status==STARTED:
                cond = 88
        
            sendTrigger(cond)
        
        
        # *breakText* updates
        if t >= 0.0 and breakText.status == NOT_STARTED:
            # keep track of start time/frame for later
            breakText.tStart = t  # underestimates by a little under one frame
            breakText.frameNStart = frameN  # exact frame index
            breakText.setAutoDraw(True)
        # *mouse* updates
        if t >= 0.0 and mouse.status == NOT_STARTED:
            # keep track of start time/frame for later
            mouse.tStart = t  # underestimates by a little under one frame
            mouse.frameNStart = frameN  # exact frame index
            mouse.status = STARTED
            event.mouseButtons = [0, 0, 0]  # reset mouse buttons to be 'up'
        if mouse.status == STARTED:  # only update if started and not stopped!
            buttons = mouse.getPressed()
            if sum(buttons) > 0:  # ie if any button is pressed
                # abort routine on response
                continueRoutine = False
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in betweenBreakComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # check for quit (the Esc key)
        if endExpNow or event.getKeys(keyList=["escape"]):
            core.quit()
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    #-------Ending Routine "betweenBreak"-------
    for thisComponent in betweenBreakComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    
    # store data for blockLoop (TrialHandler)
    x, y = mouse.getPos()
    buttons = mouse.getPressed()
    blockLoop.addData('mouse.x', x)
    blockLoop.addData('mouse.y', y)
    blockLoop.addData('mouse.leftButton', buttons[0])
    blockLoop.addData('mouse.midButton', buttons[1])
    blockLoop.addData('mouse.rightButton', buttons[2])
    # the Routine "betweenBreak" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    thisExp.nextEntry()
    
# completed 1 repeats of 'blockLoop'


#------Prepare to start Routine "endScreen"-------
t = 0
endScreenClock.reset()  # clock 
frameN = -1
# update component parameters for each repeat
portCleanup()
endResp = event.BuilderKeyResponse()  # create an object of type KeyResponse
endResp.status = NOT_STARTED
# keep track of which components have finished
endScreenComponents = []
endScreenComponents.append(endScreenText)
endScreenComponents.append(endResp)
for thisComponent in endScreenComponents:
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED

#-------Start Routine "endScreen"-------
continueRoutine = True
while continueRoutine:
    # get current time
    t = endScreenClock.getTime()
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    
    # *endScreenText* updates
    if t >= 0.0 and endScreenText.status == NOT_STARTED:
        # keep track of start time/frame for later
        endScreenText.tStart = t  # underestimates by a little under one frame
        endScreenText.frameNStart = frameN  # exact frame index
        endScreenText.setAutoDraw(True)
    
    # *endResp* updates
    if t >= 0.0 and endResp.status == NOT_STARTED:
        # keep track of start time/frame for later
        endResp.tStart = t  # underestimates by a little under one frame
        endResp.frameNStart = frameN  # exact frame index
        endResp.status = STARTED
        # keyboard checking is just starting
        win.callOnFlip(endResp.clock.reset)  # t=0 on next screen flip
        event.clearEvents(eventType='keyboard')
    if endResp.status == STARTED:
        theseKeys = event.getKeys(keyList=['space'])
        
        # check for quit:
        if "escape" in theseKeys:
            endExpNow = True
        if len(theseKeys) > 0:  # at least one key was pressed
            endResp.keys.extend(theseKeys)  # storing all keys
            endResp.rt.append(endResp.clock.getTime())
            # a response ends the routine
            continueRoutine = False
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in endScreenComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # check for quit (the Esc key)
    if endExpNow or event.getKeys(keyList=["escape"]):
        core.quit()
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

#-------Ending Routine "endScreen"-------
for thisComponent in endScreenComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
if not pulse_sent:
    cond = 69
    thisExp.addData(("expt_end_" + str(cond)), core.getTime()) 
    sendTrigger(cond)

# check responses
if endResp.keys in ['', [], None]:  # No response was made
   endResp.keys=None
# store data for thisExp (ExperimentHandler)
thisExp.addData('endResp.keys',endResp.keys)
if endResp.keys != None:  # we had a response
    thisExp.addData('endResp.rt', endResp.rt)
thisExp.nextEntry()
# the Routine "endScreen" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()









# these shouldn't be strictly necessary (should auto-save)
thisExp.saveAsWideText(filename+'.csv')
thisExp.saveAsPickle(filename)
logging.flush()
# make sure everything is closed down
thisExp.abort() # or data files will save again on exit
win.close()
core.quit()

#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
This experiment was created using PsychoPy3 Experiment Builder (v2020.1.2),
    on Thu Jul 30 15:50:42 2020
If you publish work using this script the most relevant publication is:

    Peirce J, Gray JR, Simpson S, MacAskill M, Höchenberger R, Sogo H, Kastman E, Lindeløv JK. (2019) 
        PsychoPy2: Experiments in behavior made easy Behav Res 51: 195. 
        https://doi.org/10.3758/s13428-018-01193-y

"""

from __future__ import absolute_import, division

from psychopy import locale_setup
from psychopy import prefs
from psychopy import sound, gui, visual, core, data, event, logging, clock
from psychopy.constants import (NOT_STARTED, STARTED, PLAYING, PAUSED,
                                STOPPED, FINISHED, PRESSED, RELEASED, FOREVER)

import numpy as np  # whole numpy lib is available, prepend 'np.'
from numpy import (sin, cos, tan, log, log10, pi, average,
                   sqrt, std, deg2rad, rad2deg, linspace, asarray)
from numpy.random import random, randint, normal, shuffle
import os  # handy system and path functions
import sys  # to get file system encoding

from psychopy.hardware import keyboard



# Ensure that relative paths start from the same directory as this script
_thisDir = os.path.dirname(os.path.abspath(__file__))
os.chdir(_thisDir)

# Store info about the experiment session
psychopyVersion = '2020.1.2'
expName = 'practice'  # from the Builder filename that created this script
expInfo = {'session': '001', 'participant': ''}
dlg = gui.DlgFromDict(dictionary=expInfo, sortKeys=False, title=expName)
if dlg.OK == False:
    core.quit()  # user pressed cancel
expInfo['date'] = data.getDateStr()  # add a simple timestamp
expInfo['expName'] = expName
expInfo['psychopyVersion'] = psychopyVersion

# Data file name stem = absolute path + name; later add .psyexp, .csv, .log, etc
filename = _thisDir + os.sep + os.path.join('..','raw-behavioral','s%s','%s%s%s') %(expInfo['participant'], expInfo['participant'], expName, expInfo['date'])

# An ExperimentHandler isn't essential but helps with data saving
thisExp = data.ExperimentHandler(name=expName, version='',
    extraInfo=expInfo, runtimeInfo=None,
    originPath='/Users/rhdz/workspace/eetemp/experiment-scripts/practice_lastrun.py',
    savePickle=True, saveWideText=True,
    dataFileName=filename)
# save a log file for detail verbose info
logFile = logging.LogFile(filename+'.log', level=logging.EXP)
logging.console.setLevel(logging.WARNING)  # this outputs to the screen, not a file

endExpNow = False  # flag for 'escape' or other condition => quit the exp
frameTolerance = 0.001  # how close to onset before 'same' frame

# Start Code - component code to be run before the window creation

# Setup the Window
win = visual.Window(
    size=[2560, 1440], fullscr=True, screen=0, 
    winType='pyglet', allowGUI=False, allowStencil=False,
    monitor='testMonitor', color=[0,0,0], colorSpace='rgb',
    blendMode='avg', useFBO=True)
# store frame rate of monitor if we can measure it
expInfo['frameRate'] = win.getActualFrameRate()
if expInfo['frameRate'] != None:
    frameDur = 1.0 / round(expInfo['frameRate'])
else:
    frameDur = 1.0 / 60.0  # could not measure, so guess

# create a default keyboard (e.g. to check for escape)
defaultKeyboard = keyboard.Keyboard()

# Initialize components for Routine "setPaths"
setPathsClock = core.Clock()
import yaml
import numpy
import re #this is how we get grep

config = yaml.load(open(os.path.join('..', 'config.yml'), 'r'))
directories = config['directories']
stimDir = directories['stimuli']
rawDataDir = directories['raw-behavioral-dir']
practiceStimDir = directories['practice-stimuli']

# Initialize components for Routine "instructions"
instructionsClock = core.Clock()
instrText = visual.TextStim(win=win, name='instrText',
    text='We will now practice the decision-making task you will do in this first phase. For each object you will see a yes/no question on the screen. You will use the 1 and 2 keys to respond to this question.\n\nYou will be answering one of the following four questions:\n\nWould this item fit in a bathtub?\n\nWould you find this item in a convenience store?\n\nWould this item fit in a fridge?\n\nWould you find this item in a supermarket?\n',
    font='Arial',
    pos=[0, 0], height=1, wrapWidth=30, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
instrResp = keyboard.Keyboard()

# Initialize components for Routine "trial"
trialClock = core.Clock()
image = visual.ImageStim(
    win=win,
    name='image', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
ISI = clock.StaticPeriod(win=win, screenHz=expInfo['frameRate'], name='ISI')
response = keyboard.Keyboard()
encQuestText = visual.TextStim(win=win, name='encQuestText',
    text='default text',
    font='Arial',
    pos=[0, -9], height=1, wrapWidth=25, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-4.0);
ratingScaleText = visual.TextStim(win=win, name='ratingScaleText',
    text='default text',
    font='Arial',
    pos=[0, -11], height=1, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-5.0);

# Initialize components for Routine "betweenListBreak"
betweenListBreakClock = core.Clock()
breakText = visual.TextStim(win=win, name='breakText',
    text='Do you have any questions?\n\nPlease let your experimenter know if you would like to practice this again.',
    font='Arial',
    pos=[0, 0], height=1, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
breakResp = keyboard.Keyboard()

# Initialize components for Routine "testInstructions"
testInstructionsClock = core.Clock()
RFNInstruc = visual.TextStim(win=win, name='RFNInstruc',
    text="You will now practice the test phase.\n\nIn this part, an image (either one you studied or a new object) will be presented. \n\nYour job is to judge whether or not you studied the object before. For items you think you studied, you will need to indicate if you can REMEMBER details about it (e.g., something about the image itself, the question it was paired with, the list it was in, or a thought you had about the object) or whether the object simply feels FAMILIAR (e.g., you think you studied it, but you cannot bring any specific details to mind from when you studied it).\n\nIf you think you did not study the object, you will indicate that you think the object is NEW. \n\nLet's do an example to practice making these judgments.",
    font='Arial',
    pos=[0, 0], height=1, wrapWidth=30, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
testInstrucResp = keyboard.Keyboard()

# Initialize components for Routine "RNFPractice"
RNFPracticeClock = core.Clock()
RFNPracticeImage = visual.ImageStim(
    win=win,
    name='RFNPracticeImage', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
text_2 = visual.TextStim(win=win, name='text_2',
    text='default text',
    font='Arial',
    pos=[0, -9], height=1, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-1.0);
key_resp_2 = keyboard.Keyboard()

# Initialize components for Routine "explainRFN"
explainRFNClock = core.Clock()
text_3 = visual.TextStim(win=win, name='text_3',
    text='Please explain your response.',
    font='Arial',
    pos=[0, 0], height=1.5, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
key_resp_3 = keyboard.Keyboard()

# Initialize components for Routine "testInstructions_part2"
testInstructions_part2Clock = core.Clock()
sourceInstruc = visual.TextStim(win=win, name='sourceInstruc',
    text='We will now practice the test phase as it will actually be presented to you later on.\n\nIn this part, an image (either one you studied or a new object) will be flashed quickly on the screen. \n\nAfter this, the letter "T" will appear on the screen. This is to remind you to THINK about the upcoming memory judgments. The object will then reappear and you can indicate whether or not you studied it, how confident you are in this memory judgment, and which question it was paired with during the decision-making task.\n\nDo you have any questions before we practice?',
    font='Arial',
    pos=[0, 0], height=1, wrapWidth=30, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
key_resp_4 = keyboard.Keyboard()

# Initialize components for Routine "variableITI"
variableITIClock = core.Clock()
text = visual.TextStim(win=win, name='text',
    text='+',
    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-1.0);

# Initialize components for Routine "itemRecog"
itemRecogClock = core.Clock()
image_first_presentation = visual.ImageStim(
    win=win,
    name='image_first_presentation', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
think_cue = visual.TextStim(win=win, name='think_cue',
    text='T',
    font='Arial',
    pos=[0, 0], height=2, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-1.0);
image_for_item_recog = visual.ImageStim(
    win=win,
    name='image_for_item_recog', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-2.0)
item_recog_scale = visual.TextStim(win=win, name='item_recog_scale',
    text='default text',
    font='Arial',
    pos=[0, -11], height=1, wrapWidth=25, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-3.0);
item_recog_resp = keyboard.Keyboard()

# Initialize components for Routine "itemConf"
itemConfClock = core.Clock()
image_for_item_conf = visual.ImageStim(
    win=win,
    name='image_for_item_conf', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=-1.0)
conf_resp_question = visual.TextStim(win=win, name='conf_resp_question',
    text='default text',
    font='Arial',
    pos=[0, -9], height=1, wrapWidth=35, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-2.0);
conf_resp_scale = visual.TextStim(win=win, name='conf_resp_scale',
    text='1=highly  2=moderately  3=somewhat  4=not at all',
    font='Arial',
    pos=[0, -11], height=1, wrapWidth=35, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-3.0);
item_conf_response = keyboard.Keyboard()

# Initialize components for Routine "sourceJudgment"
sourceJudgmentClock = core.Clock()
image_for_source_judgment = visual.ImageStim(
    win=win,
    name='image_for_source_judgment', 
    image='sin', mask=None,
    ori=0, pos=[0, 0], size=[15, 15],
    color=[1,1,1], colorSpace='rgb', opacity=1,
    flipHoriz=False, flipVert=False,
    texRes=128, interpolate=True, depth=0.0)
source_scale = visual.TextStim(win=win, name='source_scale',
    text='default text',
    font='Arial',
    pos=[0, -11], height=1, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=-1.0);
source_response = keyboard.Keyboard()

# Initialize components for Routine "endScreen"
endScreenClock = core.Clock()
endScreenText = visual.TextStim(win=win, name='endScreenText',
    text='You are now finished with the practice. \n\nPlease let the experimenter know if you have any questions or would like to practice again. ',
    font='Arial',
    pos=[0, 0], height=1.5, wrapWidth=None, ori=0, 
    color='white', colorSpace='rgb', opacity=1, 
    languageStyle='LTR',
    depth=0.0);
endResp = keyboard.Keyboard()

# Create some handy timers
globalClock = core.Clock()  # to track the time since experiment started
routineTimer = core.CountdownTimer()  # to track time remaining of each (non-slip) routine 

# ------Prepare to start Routine "setPaths"-------
continueRoutine = True
# update component parameters for each repeat
# keep track of which components have finished
setPathsComponents = []
for thisComponent in setPathsComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
setPathsClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "setPaths"-------
while continueRoutine:
    # get current time
    t = setPathsClock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=setPathsClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in setPathsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "setPaths"-------
for thisComponent in setPathsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
# the Routine "setPaths" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# ------Prepare to start Routine "instructions"-------
continueRoutine = True
# update component parameters for each repeat
instrResp.keys = []
instrResp.rt = []
_instrResp_allKeys = []
# keep track of which components have finished
instructionsComponents = [instrText, instrResp]
for thisComponent in instructionsComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
instructionsClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "instructions"-------
while continueRoutine:
    # get current time
    t = instructionsClock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=instructionsClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *instrText* updates
    if instrText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        instrText.frameNStart = frameN  # exact frame index
        instrText.tStart = t  # local t and not account for scr refresh
        instrText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(instrText, 'tStartRefresh')  # time at next scr refresh
        instrText.setAutoDraw(True)
    
    # *instrResp* updates
    waitOnFlip = False
    if instrResp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        instrResp.frameNStart = frameN  # exact frame index
        instrResp.tStart = t  # local t and not account for scr refresh
        instrResp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(instrResp, 'tStartRefresh')  # time at next scr refresh
        instrResp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(instrResp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(instrResp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if instrResp.status == STARTED and not waitOnFlip:
        theseKeys = instrResp.getKeys(keyList=['space'], waitRelease=False)
        _instrResp_allKeys.extend(theseKeys)
        if len(_instrResp_allKeys):
            instrResp.keys = _instrResp_allKeys[-1].name  # just the last key pressed
            instrResp.rt = _instrResp_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in instructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "instructions"-------
for thisComponent in instructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('instrText.started', instrText.tStartRefresh)
thisExp.addData('instrText.stopped', instrText.tStopRefresh)
# the Routine "instructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
encLoop = data.TrialHandler(nReps=1, method='sequential', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions(os.path.join('..', 'raw-behavioral', 's'+expInfo['participant'],'practice_enc.csv')),
    seed=None, name='encLoop')
thisExp.addLoop(encLoop)  # add the loop to the experiment
thisEncLoop = encLoop.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisEncLoop.rgb)
if thisEncLoop != None:
    for paramName in thisEncLoop:
        exec('{} = thisEncLoop[paramName]'.format(paramName))

for thisEncLoop in encLoop:
    currentLoop = encLoop
    # abbreviate parameter names if possible (e.g. rgb = thisEncLoop.rgb)
    if thisEncLoop != None:
        for paramName in thisEncLoop:
            exec('{} = thisEncLoop[paramName]'.format(paramName))
    
    # ------Prepare to start Routine "trial"-------
    continueRoutine = True
    routineTimer.add(1.750000)
    # update component parameters for each repeat
    if encQuest in ['bathtub', 'fridge']:
        encString = 'Would this item fit in a '
    elif encQuest in ['convenience store', 'supermarket']:
        encString = 'Would you find this item in a '
    image.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    response.keys = []
    response.rt = []
    _response_allKeys = []
    encQuestText.setText(encString + encQuest + '?')
    ratingScaleText.setText(encRatingScale)
    # keep track of which components have finished
    trialComponents = [image, ISI, response, encQuestText, ratingScaleText]
    for thisComponent in trialComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    trialClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "trial"-------
    while continueRoutine and routineTimer.getTime() > 0:
        # get current time
        t = trialClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=trialClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *image* updates
        if image.status == NOT_STARTED and tThisFlip >= 1.5-frameTolerance:
            # keep track of start time/frame for later
            image.frameNStart = frameN  # exact frame index
            image.tStart = t  # local t and not account for scr refresh
            image.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(image, 'tStartRefresh')  # time at next scr refresh
            image.setAutoDraw(True)
        if image.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > image.tStartRefresh + 0.25-frameTolerance:
                # keep track of stop time/frame for later
                image.tStop = t  # not accounting for scr refresh
                image.frameNStop = frameN  # exact frame index
                win.timeOnFlip(image, 'tStopRefresh')  # time at next scr refresh
                image.setAutoDraw(False)
        
        # *response* updates
        waitOnFlip = False
        if response.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
            # keep track of start time/frame for later
            response.frameNStart = frameN  # exact frame index
            response.tStart = t  # local t and not account for scr refresh
            response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(response, 'tStartRefresh')  # time at next scr refresh
            response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if response.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > response.tStartRefresh + 1.25-frameTolerance:
                # keep track of stop time/frame for later
                response.tStop = t  # not accounting for scr refresh
                response.frameNStop = frameN  # exact frame index
                win.timeOnFlip(response, 'tStopRefresh')  # time at next scr refresh
                response.status = FINISHED
        if response.status == STARTED and not waitOnFlip:
            theseKeys = response.getKeys(keyList=['f', 'g'], waitRelease=False)
            _response_allKeys.extend(theseKeys)
            if len(_response_allKeys):
                response.keys = [key.name for key in _response_allKeys]  # storing all keys
                response.rt = [key.rt for key in _response_allKeys]
        
        # *encQuestText* updates
        if encQuestText.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
            # keep track of start time/frame for later
            encQuestText.frameNStart = frameN  # exact frame index
            encQuestText.tStart = t  # local t and not account for scr refresh
            encQuestText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(encQuestText, 'tStartRefresh')  # time at next scr refresh
            encQuestText.setAutoDraw(True)
        if encQuestText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > encQuestText.tStartRefresh + 1.25-frameTolerance:
                # keep track of stop time/frame for later
                encQuestText.tStop = t  # not accounting for scr refresh
                encQuestText.frameNStop = frameN  # exact frame index
                win.timeOnFlip(encQuestText, 'tStopRefresh')  # time at next scr refresh
                encQuestText.setAutoDraw(False)
        
        # *ratingScaleText* updates
        if ratingScaleText.status == NOT_STARTED and tThisFlip >= 1.5-frameTolerance:
            # keep track of start time/frame for later
            ratingScaleText.frameNStart = frameN  # exact frame index
            ratingScaleText.tStart = t  # local t and not account for scr refresh
            ratingScaleText.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(ratingScaleText, 'tStartRefresh')  # time at next scr refresh
            ratingScaleText.setAutoDraw(True)
        if ratingScaleText.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > ratingScaleText.tStartRefresh + 0.25-frameTolerance:
                # keep track of stop time/frame for later
                ratingScaleText.tStop = t  # not accounting for scr refresh
                ratingScaleText.frameNStop = frameN  # exact frame index
                win.timeOnFlip(ratingScaleText, 'tStopRefresh')  # time at next scr refresh
                ratingScaleText.setAutoDraw(False)
        # *ISI* period
        if ISI.status == NOT_STARTED and t >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            ISI.frameNStart = frameN  # exact frame index
            ISI.tStart = t  # local t and not account for scr refresh
            ISI.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(ISI, 'tStartRefresh')  # time at next scr refresh
            ISI.start(0.5)
        elif ISI.status == STARTED:  # one frame should pass before updating params and completing
            ISI.complete()  # finish the static period
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in trialComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "trial"-------
    for thisComponent in trialComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    encLoop.addData('image.started', image.tStartRefresh)
    encLoop.addData('image.stopped', image.tStopRefresh)
    encLoop.addData('ISI.started', ISI.tStart)
    encLoop.addData('ISI.stopped', ISI.tStop)
    # check responses
    if response.keys in ['', [], None]:  # No response was made
        response.keys = None
    encLoop.addData('response.keys',response.keys)
    if response.keys != None:  # we had a response
        encLoop.addData('response.rt', response.rt)
    encLoop.addData('response.started', response.tStartRefresh)
    encLoop.addData('response.stopped', response.tStopRefresh)
    encLoop.addData('encQuestText.started', encQuestText.tStartRefresh)
    encLoop.addData('encQuestText.stopped', encQuestText.tStopRefresh)
    encLoop.addData('ratingScaleText.started', ratingScaleText.tStartRefresh)
    encLoop.addData('ratingScaleText.stopped', ratingScaleText.tStopRefresh)
    thisExp.nextEntry()
    
# completed 1 repeats of 'encLoop'


# ------Prepare to start Routine "betweenListBreak"-------
continueRoutine = True
# update component parameters for each repeat
breakResp.keys = []
breakResp.rt = []
_breakResp_allKeys = []
# keep track of which components have finished
betweenListBreakComponents = [breakText, breakResp]
for thisComponent in betweenListBreakComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
betweenListBreakClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "betweenListBreak"-------
while continueRoutine:
    # get current time
    t = betweenListBreakClock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=betweenListBreakClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *breakText* updates
    if breakText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        breakText.frameNStart = frameN  # exact frame index
        breakText.tStart = t  # local t and not account for scr refresh
        breakText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(breakText, 'tStartRefresh')  # time at next scr refresh
        breakText.setAutoDraw(True)
    
    # *breakResp* updates
    waitOnFlip = False
    if breakResp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        breakResp.frameNStart = frameN  # exact frame index
        breakResp.tStart = t  # local t and not account for scr refresh
        breakResp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(breakResp, 'tStartRefresh')  # time at next scr refresh
        breakResp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(breakResp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(breakResp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if breakResp.status == STARTED and not waitOnFlip:
        theseKeys = breakResp.getKeys(keyList=['space'], waitRelease=False)
        _breakResp_allKeys.extend(theseKeys)
        if len(_breakResp_allKeys):
            breakResp.keys = _breakResp_allKeys[-1].name  # just the last key pressed
            breakResp.rt = _breakResp_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in betweenListBreakComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "betweenListBreak"-------
for thisComponent in betweenListBreakComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('breakText.started', breakText.tStartRefresh)
thisExp.addData('breakText.stopped', breakText.tStopRefresh)
# check responses
if breakResp.keys in ['', [], None]:  # No response was made
    breakResp.keys = None
thisExp.addData('breakResp.keys',breakResp.keys)
if breakResp.keys != None:  # we had a response
    thisExp.addData('breakResp.rt', breakResp.rt)
thisExp.addData('breakResp.started', breakResp.tStartRefresh)
thisExp.addData('breakResp.stopped', breakResp.tStopRefresh)
thisExp.nextEntry()
# the Routine "betweenListBreak" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# ------Prepare to start Routine "testInstructions"-------
continueRoutine = True
# update component parameters for each repeat
testInstrucResp.keys = []
testInstrucResp.rt = []
_testInstrucResp_allKeys = []
# keep track of which components have finished
testInstructionsComponents = [RFNInstruc, testInstrucResp]
for thisComponent in testInstructionsComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
testInstructionsClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "testInstructions"-------
while continueRoutine:
    # get current time
    t = testInstructionsClock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=testInstructionsClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *RFNInstruc* updates
    if RFNInstruc.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        RFNInstruc.frameNStart = frameN  # exact frame index
        RFNInstruc.tStart = t  # local t and not account for scr refresh
        RFNInstruc.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(RFNInstruc, 'tStartRefresh')  # time at next scr refresh
        RFNInstruc.setAutoDraw(True)
    
    # *testInstrucResp* updates
    waitOnFlip = False
    if testInstrucResp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        testInstrucResp.frameNStart = frameN  # exact frame index
        testInstrucResp.tStart = t  # local t and not account for scr refresh
        testInstrucResp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(testInstrucResp, 'tStartRefresh')  # time at next scr refresh
        testInstrucResp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(testInstrucResp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(testInstrucResp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if testInstrucResp.status == STARTED and not waitOnFlip:
        theseKeys = testInstrucResp.getKeys(keyList=['space'], waitRelease=False)
        _testInstrucResp_allKeys.extend(theseKeys)
        if len(_testInstrucResp_allKeys):
            testInstrucResp.keys = _testInstrucResp_allKeys[-1].name  # just the last key pressed
            testInstrucResp.rt = _testInstrucResp_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in testInstructionsComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "testInstructions"-------
for thisComponent in testInstructionsComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('RFNInstruc.started', RFNInstruc.tStartRefresh)
thisExp.addData('RFNInstruc.stopped', RFNInstruc.tStopRefresh)
# check responses
if testInstrucResp.keys in ['', [], None]:  # No response was made
    testInstrucResp.keys = None
thisExp.addData('testInstrucResp.keys',testInstrucResp.keys)
if testInstrucResp.keys != None:  # we had a response
    thisExp.addData('testInstrucResp.rt', testInstrucResp.rt)
thisExp.addData('testInstrucResp.started', testInstrucResp.tStartRefresh)
thisExp.addData('testInstrucResp.stopped', testInstrucResp.tStopRefresh)
thisExp.nextEntry()
# the Routine "testInstructions" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
RFNPracticeLoop = data.TrialHandler(nReps=1, method='random', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions(os.path.join('..', 'raw-behavioral', 's'+expInfo['participant'],'practice_objrec.csv'), selection='1,2,3'),
    seed=None, name='RFNPracticeLoop')
thisExp.addLoop(RFNPracticeLoop)  # add the loop to the experiment
thisRFNPracticeLoop = RFNPracticeLoop.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisRFNPracticeLoop.rgb)
if thisRFNPracticeLoop != None:
    for paramName in thisRFNPracticeLoop:
        exec('{} = thisRFNPracticeLoop[paramName]'.format(paramName))

for thisRFNPracticeLoop in RFNPracticeLoop:
    currentLoop = RFNPracticeLoop
    # abbreviate parameter names if possible (e.g. rgb = thisRFNPracticeLoop.rgb)
    if thisRFNPracticeLoop != None:
        for paramName in thisRFNPracticeLoop:
            exec('{} = thisRFNPracticeLoop[paramName]'.format(paramName))
    
    # ------Prepare to start Routine "RNFPractice"-------
    continueRoutine = True
    # update component parameters for each repeat
    RFNPracticeImage.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    text_2.setText(objRecScale)
    key_resp_2.keys = []
    key_resp_2.rt = []
    _key_resp_2_allKeys = []
    # keep track of which components have finished
    RNFPracticeComponents = [RFNPracticeImage, text_2, key_resp_2]
    for thisComponent in RNFPracticeComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    RNFPracticeClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "RNFPractice"-------
    while continueRoutine:
        # get current time
        t = RNFPracticeClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=RNFPracticeClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *RFNPracticeImage* updates
        if RFNPracticeImage.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
            # keep track of start time/frame for later
            RFNPracticeImage.frameNStart = frameN  # exact frame index
            RFNPracticeImage.tStart = t  # local t and not account for scr refresh
            RFNPracticeImage.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(RFNPracticeImage, 'tStartRefresh')  # time at next scr refresh
            RFNPracticeImage.setAutoDraw(True)
        
        # *text_2* updates
        if text_2.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
            # keep track of start time/frame for later
            text_2.frameNStart = frameN  # exact frame index
            text_2.tStart = t  # local t and not account for scr refresh
            text_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(text_2, 'tStartRefresh')  # time at next scr refresh
            text_2.setAutoDraw(True)
        
        # *key_resp_2* updates
        waitOnFlip = False
        if key_resp_2.status == NOT_STARTED and tThisFlip >= 0.5-frameTolerance:
            # keep track of start time/frame for later
            key_resp_2.frameNStart = frameN  # exact frame index
            key_resp_2.tStart = t  # local t and not account for scr refresh
            key_resp_2.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(key_resp_2, 'tStartRefresh')  # time at next scr refresh
            key_resp_2.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(key_resp_2.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(key_resp_2.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if key_resp_2.status == STARTED and not waitOnFlip:
            theseKeys = key_resp_2.getKeys(keyList=['f', 'g', 'h'], waitRelease=False)
            _key_resp_2_allKeys.extend(theseKeys)
            if len(_key_resp_2_allKeys):
                key_resp_2.keys = _key_resp_2_allKeys[-1].name  # just the last key pressed
                key_resp_2.rt = _key_resp_2_allKeys[-1].rt
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in RNFPracticeComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "RNFPractice"-------
    for thisComponent in RNFPracticeComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    RFNPracticeLoop.addData('RFNPracticeImage.started', RFNPracticeImage.tStartRefresh)
    RFNPracticeLoop.addData('RFNPracticeImage.stopped', RFNPracticeImage.tStopRefresh)
    RFNPracticeLoop.addData('text_2.started', text_2.tStartRefresh)
    RFNPracticeLoop.addData('text_2.stopped', text_2.tStopRefresh)
    # check responses
    if key_resp_2.keys in ['', [], None]:  # No response was made
        key_resp_2.keys = None
    RFNPracticeLoop.addData('key_resp_2.keys',key_resp_2.keys)
    if key_resp_2.keys != None:  # we had a response
        RFNPracticeLoop.addData('key_resp_2.rt', key_resp_2.rt)
    RFNPracticeLoop.addData('key_resp_2.started', key_resp_2.tStartRefresh)
    RFNPracticeLoop.addData('key_resp_2.stopped', key_resp_2.tStopRefresh)
    # the Routine "RNFPractice" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # ------Prepare to start Routine "explainRFN"-------
    continueRoutine = True
    # update component parameters for each repeat
    key_resp_3.keys = []
    key_resp_3.rt = []
    _key_resp_3_allKeys = []
    # keep track of which components have finished
    explainRFNComponents = [text_3, key_resp_3]
    for thisComponent in explainRFNComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    explainRFNClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "explainRFN"-------
    while continueRoutine:
        # get current time
        t = explainRFNClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=explainRFNClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *text_3* updates
        if text_3.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            text_3.frameNStart = frameN  # exact frame index
            text_3.tStart = t  # local t and not account for scr refresh
            text_3.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(text_3, 'tStartRefresh')  # time at next scr refresh
            text_3.setAutoDraw(True)
        
        # *key_resp_3* updates
        waitOnFlip = False
        if key_resp_3.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            key_resp_3.frameNStart = frameN  # exact frame index
            key_resp_3.tStart = t  # local t and not account for scr refresh
            key_resp_3.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(key_resp_3, 'tStartRefresh')  # time at next scr refresh
            key_resp_3.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(key_resp_3.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(key_resp_3.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if key_resp_3.status == STARTED and not waitOnFlip:
            theseKeys = key_resp_3.getKeys(keyList=['space'], waitRelease=False)
            _key_resp_3_allKeys.extend(theseKeys)
            if len(_key_resp_3_allKeys):
                key_resp_3.keys = _key_resp_3_allKeys[-1].name  # just the last key pressed
                key_resp_3.rt = _key_resp_3_allKeys[-1].rt
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in explainRFNComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "explainRFN"-------
    for thisComponent in explainRFNComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    RFNPracticeLoop.addData('text_3.started', text_3.tStartRefresh)
    RFNPracticeLoop.addData('text_3.stopped', text_3.tStopRefresh)
    # check responses
    if key_resp_3.keys in ['', [], None]:  # No response was made
        key_resp_3.keys = None
    RFNPracticeLoop.addData('key_resp_3.keys',key_resp_3.keys)
    if key_resp_3.keys != None:  # we had a response
        RFNPracticeLoop.addData('key_resp_3.rt', key_resp_3.rt)
    RFNPracticeLoop.addData('key_resp_3.started', key_resp_3.tStartRefresh)
    RFNPracticeLoop.addData('key_resp_3.stopped', key_resp_3.tStopRefresh)
    # the Routine "explainRFN" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    thisExp.nextEntry()
    
# completed 1 repeats of 'RFNPracticeLoop'


# ------Prepare to start Routine "testInstructions_part2"-------
continueRoutine = True
# update component parameters for each repeat
key_resp_4.keys = []
key_resp_4.rt = []
_key_resp_4_allKeys = []
# keep track of which components have finished
testInstructions_part2Components = [sourceInstruc, key_resp_4]
for thisComponent in testInstructions_part2Components:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
testInstructions_part2Clock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "testInstructions_part2"-------
while continueRoutine:
    # get current time
    t = testInstructions_part2Clock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=testInstructions_part2Clock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *sourceInstruc* updates
    if sourceInstruc.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        sourceInstruc.frameNStart = frameN  # exact frame index
        sourceInstruc.tStart = t  # local t and not account for scr refresh
        sourceInstruc.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(sourceInstruc, 'tStartRefresh')  # time at next scr refresh
        sourceInstruc.setAutoDraw(True)
    
    # *key_resp_4* updates
    waitOnFlip = False
    if key_resp_4.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        key_resp_4.frameNStart = frameN  # exact frame index
        key_resp_4.tStart = t  # local t and not account for scr refresh
        key_resp_4.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(key_resp_4, 'tStartRefresh')  # time at next scr refresh
        key_resp_4.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(key_resp_4.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(key_resp_4.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if key_resp_4.status == STARTED and not waitOnFlip:
        theseKeys = key_resp_4.getKeys(keyList=['space'], waitRelease=False)
        _key_resp_4_allKeys.extend(theseKeys)
        if len(_key_resp_4_allKeys):
            key_resp_4.keys = _key_resp_4_allKeys[-1].name  # just the last key pressed
            key_resp_4.rt = _key_resp_4_allKeys[-1].rt
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in testInstructions_part2Components:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "testInstructions_part2"-------
for thisComponent in testInstructions_part2Components:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('sourceInstruc.started', sourceInstruc.tStartRefresh)
thisExp.addData('sourceInstruc.stopped', sourceInstruc.tStopRefresh)
# check responses
if key_resp_4.keys in ['', [], None]:  # No response was made
    key_resp_4.keys = None
thisExp.addData('key_resp_4.keys',key_resp_4.keys)
if key_resp_4.keys != None:  # we had a response
    thisExp.addData('key_resp_4.rt', key_resp_4.rt)
thisExp.addData('key_resp_4.started', key_resp_4.tStartRefresh)
thisExp.addData('key_resp_4.stopped', key_resp_4.tStopRefresh)
thisExp.nextEntry()
# the Routine "testInstructions_part2" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# set up handler to look after randomisation of conditions etc
responseLoop = data.TrialHandler(nReps=1, method='sequential', 
    extraInfo=expInfo, originPath=-1,
    trialList=data.importConditions(os.path.join('..', 'raw-behavioral', 's'+expInfo['participant'],'practice_objrec.csv')),
    seed=None, name='responseLoop')
thisExp.addLoop(responseLoop)  # add the loop to the experiment
thisResponseLoop = responseLoop.trialList[0]  # so we can initialise stimuli with some values
# abbreviate parameter names if possible (e.g. rgb = thisResponseLoop.rgb)
if thisResponseLoop != None:
    for paramName in thisResponseLoop:
        exec('{} = thisResponseLoop[paramName]'.format(paramName))

for thisResponseLoop in responseLoop:
    currentLoop = responseLoop
    # abbreviate parameter names if possible (e.g. rgb = thisResponseLoop.rgb)
    if thisResponseLoop != None:
        for paramName in thisResponseLoop:
            exec('{} = thisResponseLoop[paramName]'.format(paramName))
    
    # ------Prepare to start Routine "variableITI"-------
    continueRoutine = True
    # update component parameters for each repeat
    # based on https://groups.google.com/forum/#!topic/psychopy-users/PqbP5cNu7Vc
    fixDuration = random() + 1.7
    
    # keep track of which components have finished
    variableITIComponents = [text]
    for thisComponent in variableITIComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    variableITIClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "variableITI"-------
    while continueRoutine:
        # get current time
        t = variableITIClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=variableITIClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *text* updates
        if text.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            text.frameNStart = frameN  # exact frame index
            text.tStart = t  # local t and not account for scr refresh
            text.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(text, 'tStartRefresh')  # time at next scr refresh
            text.setAutoDraw(True)
        if text.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > text.tStartRefresh + fixDuration-frameTolerance:
                # keep track of stop time/frame for later
                text.tStop = t  # not accounting for scr refresh
                text.frameNStop = frameN  # exact frame index
                win.timeOnFlip(text, 'tStopRefresh')  # time at next scr refresh
                text.setAutoDraw(False)
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in variableITIComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "variableITI"-------
    for thisComponent in variableITIComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    thisExp.addData("ITI_duration", fixDuration) 
    responseLoop.addData('text.started', text.tStartRefresh)
    responseLoop.addData('text.stopped', text.tStopRefresh)
    # the Routine "variableITI" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # ------Prepare to start Routine "itemRecog"-------
    continueRoutine = True
    # update component parameters for each repeat
    image_first_presentation.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    image_for_item_recog.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    item_recog_scale.setText(objRecScale)
    item_recog_resp.keys = []
    item_recog_resp.rt = []
    _item_recog_resp_allKeys = []
    # keep track of which components have finished
    itemRecogComponents = [image_first_presentation, think_cue, image_for_item_recog, item_recog_scale, item_recog_resp]
    for thisComponent in itemRecogComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    itemRecogClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "itemRecog"-------
    while continueRoutine:
        # get current time
        t = itemRecogClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=itemRecogClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *image_first_presentation* updates
        if image_first_presentation.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            image_first_presentation.frameNStart = frameN  # exact frame index
            image_first_presentation.tStart = t  # local t and not account for scr refresh
            image_first_presentation.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(image_first_presentation, 'tStartRefresh')  # time at next scr refresh
            image_first_presentation.setAutoDraw(True)
        if image_first_presentation.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > image_first_presentation.tStartRefresh + 0.7-frameTolerance:
                # keep track of stop time/frame for later
                image_first_presentation.tStop = t  # not accounting for scr refresh
                image_first_presentation.frameNStop = frameN  # exact frame index
                win.timeOnFlip(image_first_presentation, 'tStopRefresh')  # time at next scr refresh
                image_first_presentation.setAutoDraw(False)
        
        # *think_cue* updates
        if think_cue.status == NOT_STARTED and tThisFlip >= 0.7-frameTolerance:
            # keep track of start time/frame for later
            think_cue.frameNStart = frameN  # exact frame index
            think_cue.tStart = t  # local t and not account for scr refresh
            think_cue.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(think_cue, 'tStartRefresh')  # time at next scr refresh
            think_cue.setAutoDraw(True)
        if think_cue.status == STARTED:
            # is it time to stop? (based on global clock, using actual start)
            if tThisFlipGlobal > think_cue.tStartRefresh + 1.7-frameTolerance:
                # keep track of stop time/frame for later
                think_cue.tStop = t  # not accounting for scr refresh
                think_cue.frameNStop = frameN  # exact frame index
                win.timeOnFlip(think_cue, 'tStopRefresh')  # time at next scr refresh
                think_cue.setAutoDraw(False)
        
        # *image_for_item_recog* updates
        if image_for_item_recog.status == NOT_STARTED and tThisFlip >= 2.4-frameTolerance:
            # keep track of start time/frame for later
            image_for_item_recog.frameNStart = frameN  # exact frame index
            image_for_item_recog.tStart = t  # local t and not account for scr refresh
            image_for_item_recog.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(image_for_item_recog, 'tStartRefresh')  # time at next scr refresh
            image_for_item_recog.setAutoDraw(True)
        
        # *item_recog_scale* updates
        if item_recog_scale.status == NOT_STARTED and tThisFlip >= 2.4-frameTolerance:
            # keep track of start time/frame for later
            item_recog_scale.frameNStart = frameN  # exact frame index
            item_recog_scale.tStart = t  # local t and not account for scr refresh
            item_recog_scale.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(item_recog_scale, 'tStartRefresh')  # time at next scr refresh
            item_recog_scale.setAutoDraw(True)
        
        # *item_recog_resp* updates
        waitOnFlip = False
        if item_recog_resp.status == NOT_STARTED and tThisFlip >= 2.4-frameTolerance:
            # keep track of start time/frame for later
            item_recog_resp.frameNStart = frameN  # exact frame index
            item_recog_resp.tStart = t  # local t and not account for scr refresh
            item_recog_resp.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(item_recog_resp, 'tStartRefresh')  # time at next scr refresh
            item_recog_resp.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(item_recog_resp.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(item_recog_resp.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if item_recog_resp.status == STARTED and not waitOnFlip:
            theseKeys = item_recog_resp.getKeys(keyList=['f', 'g', 'h'], waitRelease=False)
            _item_recog_resp_allKeys.extend(theseKeys)
            if len(_item_recog_resp_allKeys):
                item_recog_resp.keys = [key.name for key in _item_recog_resp_allKeys]  # storing all keys
                item_recog_resp.rt = [key.rt for key in _item_recog_resp_allKeys]
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in itemRecogComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "itemRecog"-------
    for thisComponent in itemRecogComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    responseLoop.addData('image_first_presentation.started', image_first_presentation.tStartRefresh)
    responseLoop.addData('image_first_presentation.stopped', image_first_presentation.tStopRefresh)
    responseLoop.addData('think_cue.started', think_cue.tStartRefresh)
    responseLoop.addData('think_cue.stopped', think_cue.tStopRefresh)
    responseLoop.addData('image_for_item_recog.started', image_for_item_recog.tStartRefresh)
    responseLoop.addData('image_for_item_recog.stopped', image_for_item_recog.tStopRefresh)
    responseLoop.addData('item_recog_scale.started', item_recog_scale.tStartRefresh)
    responseLoop.addData('item_recog_scale.stopped', item_recog_scale.tStopRefresh)
    # check responses
    if item_recog_resp.keys in ['', [], None]:  # No response was made
        item_recog_resp.keys = None
    responseLoop.addData('item_recog_resp.keys',item_recog_resp.keys)
    if item_recog_resp.keys != None:  # we had a response
        responseLoop.addData('item_recog_resp.rt', item_recog_resp.rt)
    responseLoop.addData('item_recog_resp.started', item_recog_resp.tStartRefresh)
    responseLoop.addData('item_recog_resp.stopped', item_recog_resp.tStopRefresh)
    # the Routine "itemRecog" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # ------Prepare to start Routine "itemConf"-------
    continueRoutine = True
    # update component parameters for each repeat
    resp = (item_recog_resp.keys[0])
    if resp=='f':
        num_resp = 1
    elif resp=='g':
        num_resp = 2
    elif resp=='h':
        num_resp = 3
    
    # convert response columns from numpy.int64 to int
    rem_resp = numpy.asscalar(rememberResp)
    fam_resp = numpy.asscalar(familiarResp)
    new_resp = numpy.asscalar(newResp)
    
    if numpy.equal(num_resp, rem_resp):
        objConfScale = 'How confident are you that you REMEMBER the item?'
    elif numpy.equal(num_resp, fam_resp):
        objConfScale = 'How confident are you that the item is FAMILIAR?'
    elif numpy.equal(num_resp, new_resp):
        objConfScale = 'How confident are you that the item is NEW?'
    image_for_item_conf.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    conf_resp_question.setText(objConfScale)
    item_conf_response.keys = []
    item_conf_response.rt = []
    _item_conf_response_allKeys = []
    # keep track of which components have finished
    itemConfComponents = [image_for_item_conf, conf_resp_question, conf_resp_scale, item_conf_response]
    for thisComponent in itemConfComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    itemConfClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "itemConf"-------
    while continueRoutine:
        # get current time
        t = itemConfClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=itemConfClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *image_for_item_conf* updates
        if image_for_item_conf.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            image_for_item_conf.frameNStart = frameN  # exact frame index
            image_for_item_conf.tStart = t  # local t and not account for scr refresh
            image_for_item_conf.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(image_for_item_conf, 'tStartRefresh')  # time at next scr refresh
            image_for_item_conf.setAutoDraw(True)
        
        # *conf_resp_question* updates
        if conf_resp_question.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            conf_resp_question.frameNStart = frameN  # exact frame index
            conf_resp_question.tStart = t  # local t and not account for scr refresh
            conf_resp_question.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(conf_resp_question, 'tStartRefresh')  # time at next scr refresh
            conf_resp_question.setAutoDraw(True)
        
        # *conf_resp_scale* updates
        if conf_resp_scale.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            conf_resp_scale.frameNStart = frameN  # exact frame index
            conf_resp_scale.tStart = t  # local t and not account for scr refresh
            conf_resp_scale.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(conf_resp_scale, 'tStartRefresh')  # time at next scr refresh
            conf_resp_scale.setAutoDraw(True)
        
        # *item_conf_response* updates
        waitOnFlip = False
        if item_conf_response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            item_conf_response.frameNStart = frameN  # exact frame index
            item_conf_response.tStart = t  # local t and not account for scr refresh
            item_conf_response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(item_conf_response, 'tStartRefresh')  # time at next scr refresh
            item_conf_response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(item_conf_response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(item_conf_response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if item_conf_response.status == STARTED and not waitOnFlip:
            theseKeys = item_conf_response.getKeys(keyList=['f', 'g', 'h', 'j'], waitRelease=False)
            _item_conf_response_allKeys.extend(theseKeys)
            if len(_item_conf_response_allKeys):
                item_conf_response.keys = _item_conf_response_allKeys[-1].name  # just the last key pressed
                item_conf_response.rt = _item_conf_response_allKeys[-1].rt
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in itemConfComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "itemConf"-------
    for thisComponent in itemConfComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    responseLoop.addData('image_for_item_conf.started', image_for_item_conf.tStartRefresh)
    responseLoop.addData('image_for_item_conf.stopped', image_for_item_conf.tStopRefresh)
    responseLoop.addData('conf_resp_question.started', conf_resp_question.tStartRefresh)
    responseLoop.addData('conf_resp_question.stopped', conf_resp_question.tStopRefresh)
    responseLoop.addData('conf_resp_scale.started', conf_resp_scale.tStartRefresh)
    responseLoop.addData('conf_resp_scale.stopped', conf_resp_scale.tStopRefresh)
    # check responses
    if item_conf_response.keys in ['', [], None]:  # No response was made
        item_conf_response.keys = None
    responseLoop.addData('item_conf_response.keys',item_conf_response.keys)
    if item_conf_response.keys != None:  # we had a response
        responseLoop.addData('item_conf_response.rt', item_conf_response.rt)
    responseLoop.addData('item_conf_response.started', item_conf_response.tStartRefresh)
    responseLoop.addData('item_conf_response.stopped', item_conf_response.tStopRefresh)
    # the Routine "itemConf" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    
    # ------Prepare to start Routine "sourceJudgment"-------
    continueRoutine = True
    # update component parameters for each repeat
    image_for_source_judgment.setImage(os.path.join(practiceStimDir,'Object%03d_noWhite.png')%(stim))
    source_scale.setText('What question did you answer earlier about this item?\n1 - %s\n2 - %s\n3 - %s\n4 - %s' %(q1,q2,q3,q4))
    source_response.keys = []
    source_response.rt = []
    _source_response_allKeys = []
    # keep track of which components have finished
    sourceJudgmentComponents = [image_for_source_judgment, source_scale, source_response]
    for thisComponent in sourceJudgmentComponents:
        thisComponent.tStart = None
        thisComponent.tStop = None
        thisComponent.tStartRefresh = None
        thisComponent.tStopRefresh = None
        if hasattr(thisComponent, 'status'):
            thisComponent.status = NOT_STARTED
    # reset timers
    t = 0
    _timeToFirstFrame = win.getFutureFlipTime(clock="now")
    sourceJudgmentClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
    frameN = -1
    
    # -------Run Routine "sourceJudgment"-------
    while continueRoutine:
        # get current time
        t = sourceJudgmentClock.getTime()
        tThisFlip = win.getFutureFlipTime(clock=sourceJudgmentClock)
        tThisFlipGlobal = win.getFutureFlipTime(clock=None)
        frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
        # update/draw components on each frame
        
        # *image_for_source_judgment* updates
        if image_for_source_judgment.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            image_for_source_judgment.frameNStart = frameN  # exact frame index
            image_for_source_judgment.tStart = t  # local t and not account for scr refresh
            image_for_source_judgment.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(image_for_source_judgment, 'tStartRefresh')  # time at next scr refresh
            image_for_source_judgment.setAutoDraw(True)
        
        # *source_scale* updates
        if source_scale.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            source_scale.frameNStart = frameN  # exact frame index
            source_scale.tStart = t  # local t and not account for scr refresh
            source_scale.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(source_scale, 'tStartRefresh')  # time at next scr refresh
            source_scale.setAutoDraw(True)
        
        # *source_response* updates
        waitOnFlip = False
        if source_response.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
            # keep track of start time/frame for later
            source_response.frameNStart = frameN  # exact frame index
            source_response.tStart = t  # local t and not account for scr refresh
            source_response.tStartRefresh = tThisFlipGlobal  # on global time
            win.timeOnFlip(source_response, 'tStartRefresh')  # time at next scr refresh
            source_response.status = STARTED
            # keyboard checking is just starting
            waitOnFlip = True
            win.callOnFlip(source_response.clock.reset)  # t=0 on next screen flip
            win.callOnFlip(source_response.clearEvents, eventType='keyboard')  # clear events on next screen flip
        if source_response.status == STARTED and not waitOnFlip:
            theseKeys = source_response.getKeys(keyList=['f', 'g', 'h', 'j'], waitRelease=False)
            _source_response_allKeys.extend(theseKeys)
            if len(_source_response_allKeys):
                source_response.keys = [key.name for key in _source_response_allKeys]  # storing all keys
                source_response.rt = [key.rt for key in _source_response_allKeys]
                # a response ends the routine
                continueRoutine = False
        
        # check for quit (typically the Esc key)
        if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
            core.quit()
        
        # check if all components have finished
        if not continueRoutine:  # a component has requested a forced-end of Routine
            break
        continueRoutine = False  # will revert to True if at least one component still running
        for thisComponent in sourceJudgmentComponents:
            if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
                continueRoutine = True
                break  # at least one component has not yet finished
        
        # refresh the screen
        if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
            win.flip()
    
    # -------Ending Routine "sourceJudgment"-------
    for thisComponent in sourceJudgmentComponents:
        if hasattr(thisComponent, "setAutoDraw"):
            thisComponent.setAutoDraw(False)
    responseLoop.addData('image_for_source_judgment.started', image_for_source_judgment.tStartRefresh)
    responseLoop.addData('image_for_source_judgment.stopped', image_for_source_judgment.tStopRefresh)
    responseLoop.addData('source_scale.started', source_scale.tStartRefresh)
    responseLoop.addData('source_scale.stopped', source_scale.tStopRefresh)
    # check responses
    if source_response.keys in ['', [], None]:  # No response was made
        source_response.keys = None
    responseLoop.addData('source_response.keys',source_response.keys)
    if source_response.keys != None:  # we had a response
        responseLoop.addData('source_response.rt', source_response.rt)
    responseLoop.addData('source_response.started', source_response.tStartRefresh)
    responseLoop.addData('source_response.stopped', source_response.tStopRefresh)
    # the Routine "sourceJudgment" was not non-slip safe, so reset the non-slip timer
    routineTimer.reset()
    thisExp.nextEntry()
    
# completed 1 repeats of 'responseLoop'


# ------Prepare to start Routine "endScreen"-------
continueRoutine = True
# update component parameters for each repeat
endResp.keys = []
endResp.rt = []
_endResp_allKeys = []
# keep track of which components have finished
endScreenComponents = [endScreenText, endResp]
for thisComponent in endScreenComponents:
    thisComponent.tStart = None
    thisComponent.tStop = None
    thisComponent.tStartRefresh = None
    thisComponent.tStopRefresh = None
    if hasattr(thisComponent, 'status'):
        thisComponent.status = NOT_STARTED
# reset timers
t = 0
_timeToFirstFrame = win.getFutureFlipTime(clock="now")
endScreenClock.reset(-_timeToFirstFrame)  # t0 is time of first possible flip
frameN = -1

# -------Run Routine "endScreen"-------
while continueRoutine:
    # get current time
    t = endScreenClock.getTime()
    tThisFlip = win.getFutureFlipTime(clock=endScreenClock)
    tThisFlipGlobal = win.getFutureFlipTime(clock=None)
    frameN = frameN + 1  # number of completed frames (so 0 is the first frame)
    # update/draw components on each frame
    
    # *endScreenText* updates
    if endScreenText.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        endScreenText.frameNStart = frameN  # exact frame index
        endScreenText.tStart = t  # local t and not account for scr refresh
        endScreenText.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(endScreenText, 'tStartRefresh')  # time at next scr refresh
        endScreenText.setAutoDraw(True)
    
    # *endResp* updates
    waitOnFlip = False
    if endResp.status == NOT_STARTED and tThisFlip >= 0.0-frameTolerance:
        # keep track of start time/frame for later
        endResp.frameNStart = frameN  # exact frame index
        endResp.tStart = t  # local t and not account for scr refresh
        endResp.tStartRefresh = tThisFlipGlobal  # on global time
        win.timeOnFlip(endResp, 'tStartRefresh')  # time at next scr refresh
        endResp.status = STARTED
        # keyboard checking is just starting
        waitOnFlip = True
        win.callOnFlip(endResp.clock.reset)  # t=0 on next screen flip
        win.callOnFlip(endResp.clearEvents, eventType='keyboard')  # clear events on next screen flip
    if endResp.status == STARTED and not waitOnFlip:
        theseKeys = endResp.getKeys(keyList=['space'], waitRelease=False)
        _endResp_allKeys.extend(theseKeys)
        if len(_endResp_allKeys):
            endResp.keys = [key.name for key in _endResp_allKeys]  # storing all keys
            endResp.rt = [key.rt for key in _endResp_allKeys]
            # a response ends the routine
            continueRoutine = False
    
    # check for quit (typically the Esc key)
    if endExpNow or defaultKeyboard.getKeys(keyList=["escape"]):
        core.quit()
    
    # check if all components have finished
    if not continueRoutine:  # a component has requested a forced-end of Routine
        break
    continueRoutine = False  # will revert to True if at least one component still running
    for thisComponent in endScreenComponents:
        if hasattr(thisComponent, "status") and thisComponent.status != FINISHED:
            continueRoutine = True
            break  # at least one component has not yet finished
    
    # refresh the screen
    if continueRoutine:  # don't flip if this routine is over or we'll get a blank screen
        win.flip()

# -------Ending Routine "endScreen"-------
for thisComponent in endScreenComponents:
    if hasattr(thisComponent, "setAutoDraw"):
        thisComponent.setAutoDraw(False)
thisExp.addData('endScreenText.started', endScreenText.tStartRefresh)
thisExp.addData('endScreenText.stopped', endScreenText.tStopRefresh)
# check responses
if endResp.keys in ['', [], None]:  # No response was made
    endResp.keys = None
thisExp.addData('endResp.keys',endResp.keys)
if endResp.keys != None:  # we had a response
    thisExp.addData('endResp.rt', endResp.rt)
thisExp.addData('endResp.started', endResp.tStartRefresh)
thisExp.addData('endResp.stopped', endResp.tStopRefresh)
thisExp.nextEntry()
# the Routine "endScreen" was not non-slip safe, so reset the non-slip timer
routineTimer.reset()

# Flip one final time so any remaining win.callOnFlip() 
# and win.timeOnFlip() tasks get executed before quitting
win.flip()

# these shouldn't be strictly necessary (should auto-save)
thisExp.saveAsWideText(filename+'.csv')
thisExp.saveAsPickle(filename)
logging.flush()
# make sure everything is closed down
thisExp.abort()  # or data files will save again on exit
win.close()
core.quit()

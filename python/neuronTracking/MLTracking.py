# -*- coding: utf-8 -*-
"""
script to load dataset and try tracking neurons using ML approaches
"""

import warnings
warnings.filterwarnings('ignore')

%matplotlib inline
import matplotlib.pyplot as plt
import numpy as np


#load up our data


import scipy.io
#math = scipy.io.loadmat('M1 Stevenson Binned.mat')

math.keys()


##calculate features
#INPUT:
#-shape 
#    -d' distance(principle components?)
#    -scaling factor
#    -SNR
#-isi distribution
#    -histogram bins of ISI for ~5bins. Bins need not be uniform size
#    -5ms, 10ms, 30ms, 70ms, 150ms?
#-same/diff elec
#    -diff elec is null
#    -same elec is noisy match
#-same/diff task
#    -gross task lable
#    -kinematic summary params (mean speed, time reaching/timesInHold,...)
#OUTPUT:
#-same/diff elec flag
#    -diff elec is substitute for known different units
#    -same elec is substitute for noisy same unit    


##utility functions

def poisson_pseudoR2(y, yhat, ynull):
    eps = np.spacing(1)
    L1 = np.sum(y*np.log(eps+yhat) - yhat)
    L1_v = y*np.log(eps+yhat) - yhat
    L0 = np.sum(y*np.log(eps+ynull) - ynull)
    LS = np.sum(y*np.log(eps+y) - y)
    R2 = 1-(LS-L1)/(LS-L0)
    return R2

import xgboost as xgb
def XGB_bernoulli(Xr, Yr, Xt):
    #param = {'objective': "count:poisson",
    #'eval_metric': "logloss",
    param = {'objective',"binary:logistic",
    'eval_metric',"error",
    'num_parallel_tree': 2,
    'eta': 0.07,
    'gamma': 1, # default = 0
    'max_depth': 1,
    'subsample': 0.5,
    'seed': 2925,
    'silent': 1,
    'missing': '-999.0'}
    param['nthread'] = 6

    dtrain = xgb.DMatrix(Xr, label=Yr)
    dtest = xgb.DMatrix(Xt)

    num_round = 200
    bst = xgb.train(param, dtrain, num_round)

    Yt = bst.predict(dtest)
    return Yt

from pyglmnet import GLM
def glm_bernoulli_pyglmnet(Xr, Yr, Xt):
    #poissonexp isn't listed as an option for distr?
    #glm = GLM(distr='poissonexp', alpha=0., reg_lambda=[0.], tol=1e-6)
    glm = GLM(distr='binomial', alpha=0., reg_lambda=[0.], tol=1e-6)
    glm.fit(Xr, Yr)
    Yt = glm.predict(Xt)[0]
    return Yt

from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation
from keras.layers.core import Lambda
def glm_bernoulli_keras(Xr, Yr, Xt):
    model = Sequential()
    model.add(Dense(1, input_dim=np.shape(Xr)[1], init='uniform', activation='linear'))
    model.add(Lambda(lambda x: np.exp(x)))
    #model.compile(loss='poisson', optimizer='rmsprop')
    model.compile(loss='binary_crossentropy',optimizer='rmsprop')
    model.fit(Xr, Yr, nb_epoch=3, batch_size=16, verbose=0, validation_split=0.0)
    Yt = model.predict_proba(Xt, verbose=0)
    return Yt[:,0]

def NN_bernoulli(Xr,Yr, Xt):
    if np.ndim(Xr)==1:
        Xr = np.transpose(np.atleast_2d(Xr))
    
    model = Sequential()
    model.add(Dense(3000, input_dim=np.shape(Xr)[1], init='uniform', activation='tanh'))
    model.add(Dropout(0.6))
    model.add(Dense(100, init='uniform', activation='tanh'))
    model.add(Dropout(0.6))
    model.add(Dense(1, activation='linear'))
    model.add(Lambda(lambda x: np.exp(x)))
    #model.compile(loss='poisson', optimizer='adam')
    model.compile(loss='binary_crossentropy',optimizer='adam')
    hist = model.fit(Xr, Yr, nb_epoch=3, batch_size=32, verbose=1, validation_split=0.0)
    result = model.predict_proba(Xt)
    return result[:,0]

def fit_cv(X, Y, algorithm = 'XGB_bernoulli', n_cv=10, verbose=1, label=[]):
    if np.ndim(X)==1:
        X = np.transpose(np.atleast_2d(X))

    if len(label)>0:
        skf  = LabelKFold(np.squeeze(label), n_folds=n_cv)
    else:
        skf  = KFold(n=np.size(Y), n_folds=n_cv, shuffle=True, random_state=42)

    i=1
    Y_hat=np.zeros(len(Y))
    pR2_cv = list()
    for idx_r, idx_t in skf:
        if verbose > 1:
            print '...runnning cv-fold', i, 'of', n_cv
        i+=1
        Xr = X[idx_r, :]
        Yr = Y[idx_r]
        Xt = X[idx_t, :]
        Yt = Y[idx_t]

        Yt_hat = eval(algorithm)(Xr, Yr, Xt)
        Y_hat[idx_t] = Yt_hat

        pR2 = poisson_pseudoR2(Yt, Yt_hat, np.mean(Yr))
        pR2_cv.append(pR2)

        if verbose > 1:
            print 'pR2: ', pR2

    if verbose > 0:
        print("pR2_cv: %0.6f (+/- %0.6f)" % (np.mean(pR2_cv),
                                             np.std(pR2_cv)/np.sqrt(n_cv)))

    return Y_hat, pR2_cv


#estimate same/diff using GLM (pyglmnet)
Yt_hat_glm_pyglmnet = glm_bernoulli_pyglmnet(X,y,Xangles)

#estimate same/diff using GLM (keras)
Yt_hat_glm_keras = glm_bernoulli_keras(X, y, Xangles)

#estimate same/diff using FFNN
Yt_hat_NN = NN_bernoulli(X, y, Xangles)

#estimate same/diff using XGB
Yt_hat_XGB = XGB_bernoulli(X, y, Xangles)

#see if using XGB on the output of GLM, NN and XGB improves things any
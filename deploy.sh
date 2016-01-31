#!/bin/bash

stack exec -- stephen-planetbarr-com clean
stack exec -- stephen-planetbarr-com build
stack exec -- stephen-planetbarr-com deploy



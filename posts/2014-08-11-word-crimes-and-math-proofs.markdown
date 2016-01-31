---
layout: post
title: "Word Crimes and Math Proofs"
date: 2014-08-11 22:56:14 -0700
comments: true
description: The intersection of Weird Al and Math
tags: humor, math
---

[Weird Al Yankovic](http://www.weirdal.com/) recently released a batch of new songs. For the uninformed, Weird Al is synonymous with comedic musical parody. One of his newest songs is "Word Crimes", a parody of "Blurred Lines". One of the lyrics in Word Crimes is the following:

<blockquote>
<p>I hate these word crimes,</p>
<p>Like "I could care less."</p>
<p>That means you do care,<p>
<p>At least a little.<p>
</blockquote>

This parallels proofs that we often use in math, particularly optimization.
For example, suppose you were trying to prove that there was no smallest number greater than 0.
One way of stating this is that for any $x > 0$, you can find an $\epsilon > 0$  such that $\epsilon < x$.
In other words, for any $x > 0$, you can find an $\epsilon > 0$ which is also smaller than $x$.
A candidate $\epsilon$ is $\epsilon = x/2$.
This works because (1) dividing a positive number ($x$) by another positive number ($2$) is still positive, and (2) for any positive $x$, it is true that $ x /2 < x$.
Therefore, for $\epsilon = x/2$, the argument holds.

This is exactly what Weird Al is saying.
By saying "I could care less", you are saying that you currently care at level $x$, and there is some smaller value $\epsilon$ such that if you cared at level $\epsilon$ you would care at a lower level, while still actually caring.

The pictures from the video explain it nicely:

<img src ="/images/wc1.png">

<img src ="/images/wc2.png">

<img src = "/images/wc3.png">

The video is worth watching:

<iframe width="560" height="315" src="https://www.youtube.com/embed/8Gv0H-vPoDc" frameborder="0" allowfullscreen></iframe>


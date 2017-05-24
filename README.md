<p align="center">
<img alt="AppFriends" src="http://res.cloudinary.com/hacknocraft-appfriends/image/upload/v1493399164/hc_logo_aifap3.png" width=200 />
<br />
<br />
Hacknocraft Async Item Queue
<br />
<br />

# What does it do?
Often we need to put tasks such as requests to the server into a queue. Then at certain frequency, the executer takes pending items from a queue to execute. When the execution is successful, we want to remove the items. However, we need to remember which items are current being executed, so that we don't end up removing items added to the queue while the execution is happening. This library handles the situation.

# Offline and Persistence Support
This queue will persist after the app is turned off. The task items will be saved.

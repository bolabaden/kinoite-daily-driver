# Swap and zram

Fedora often enables **zram** by default. For heavy builds, consider a **swap file** on a fast disk on **bare metal**.

Inside **WSL2**, memory policy is dominated by **Windows host RAM** — tune **`.wslconfig`** on Windows if you OOM during large exports.

#!/bin/bash

set -e

# Function to create swap file
create_swap() {
    local size_gb=$1
    local swap_file="/var/cache/swap/swapfile"
    
    echo "Creating swap file of size ${size_gb}GB..."
    
    # Create directory if it doesn't exist
    sudo mkdir -p /var/cache/swap
    
    # Convert GB to MB
    local size_mb=$((size_gb * 1024))
    
    # Create swap file
    sudo dd if=/dev/zero of=$swap_file bs=1M count=$size_mb
    sudo chmod 600 $swap_file
    
    # Setup swap
    sudo mkswap $swap_file
    sudo swapon $swap_file
    
    # Update /etc/fstab
    echo "$swap_file none swap sw 0 0" | sudo tee -a /etc/fstab
    
    echo "Swap file created and activated."
    sudo swapon -s
}

# Function to remove swap file
remove_swap() {
    local swap_file="/var/cache/swap/swapfile"
    
    echo "Removing swap file..."
    
    # Turn off swap
    sudo swapoff $swap_file || { echo "Failed to turn off swap"; exit 1; }
    
    # Remove swap entry from /etc/fstab
    sudo sed -i "\|$swap_file|d" /etc/fstab || { echo "Failed to remove entry from /etc/fstab"; exit 1; }
    
    # Remove swap file
    sudo rm -f $swap_file || { echo "Failed to remove swap file"; exit 1; }
    
    echo "Swap file removed."
    sudo swapon -s
}

# Main menu
echo "Choose an option:"
echo "1. Create swap file"
echo "2. Remove swap file"
echo -n "Enter your choice (1/2): "
read choice

case $choice in
    1)
        echo -n "Enter the size of swap file in GB: "
        read size_gb
        create_swap $size_gb
        ;;
    2)
        remove_swap
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

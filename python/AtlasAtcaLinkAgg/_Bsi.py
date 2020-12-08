#!/usr/bin/env python
#-----------------------------------------------------------------------------
# Title      : PyRogue AmcCarrier BSI Module
#-----------------------------------------------------------------------------
# File       : AmcCarrierBsi.py
# Created    : 2017-04-04
#-----------------------------------------------------------------------------
# Description:
# PyRogue AmcCarrier BSI Module
#-----------------------------------------------------------------------------
# This file is part of the rogue software platform. It is subject to
# the license terms in the LICENSE.txt file found in the top-level directory
# of this distribution and at:
#    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
# No part of the rogue software platform, including this file, may be
# copied, modified, propagated, or distributed except according to the terms
# contained in the LICENSE.txt file.
#-----------------------------------------------------------------------------

import pyrogue as pr

import surf.ethernet.udp    as udp

class Bsi(pr.Device):
    def __init__(   self,
            name        = 'Bsi',
            description = 'Container for BSI Module',
            **kwargs):
        super().__init__(name=name, description=description, **kwargs)

        ##############################
        # Variables
        ##############################

        for i in range(6):

            self.add(pr.RemoteVariable(
                name         = f'MacAddress[{i}]',
                description  = 'MacAddress (big-Endian configuration)',
                offset       = 8*i,
                bitSize      = 48,
                mode         = 'RO',
                hidden       = True,
            ))

            self.add(pr.LinkVariable(
                name         = f'MAC[{i}]',
                description  = 'MacAddress (human readable)',
                mode         = 'RO',
                linkedGet    = udp.getMacValue,
                dependencies = [self.variables[f'MacAddress[{i}]']],
            ))

        for i in range(6):

            self.add(pr.RemoteVariable(
                name         = f'EthUpTime[{i}]',
                description  = 'Number of seconds since ETH Link Up',
                offset       = 4*i+64,
                bitSize      = 32,
                mode         = 'RO',
                disp         = '{:d}',
                units        = 'seconds',
                pollInterval = 1,
            ))

        self.add(pr.RemoteVariable(
            name         = 'CrateId',
            description  = 'ATCA Crate ID',
            offset       =  0x80,
            bitSize      =  16,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'SlotNumber',
            description  = 'ATCA Logical Slot Number',
            offset       =  0x84,
            bitSize      =  4,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'BootStartAddress',
            description  = 'Bootloader Start Address',
            offset       =  0x88,
            bitSize      =  32,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'VersionMinor',
            description  = 'BSI Minor Version Number',
            offset       =  0x8C,
            bitSize      =  8,
            bitOffset    =  0,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'VersionMajor',
            description  = 'BSI Major Version Number',
            offset       =  0x90,
            bitSize      =  8,
            bitOffset    =  8,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'EthLinkUp',
            description  = 'ETH Link Up',
            offset       =  0x90,
            bitSize      =  6,
            bitOffset    =  16,
            mode         = 'RO',
        ))

        self.add(pr.RemoteVariable(
            name         = 'ForceLedRed',
            description  = 'Force Front Panel RED LED',
            offset       =  0x94,
            bitSize      =  2,
            bitOffset    =  0,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'ForceLedBlue',
            description  = 'Force Front Panel BLUE LED',
            offset       =  0x94,
            bitSize      =  2,
            bitOffset    =  8,
            mode         = 'RW',
        ))

        self.add(pr.RemoteVariable(
            name         = 'ForceLedGreen',
            description  = 'Force Front Panel GREEN LED',
            offset       =  0x94,
            bitSize      =  2,
            bitOffset    =  16,
            mode         = 'RW',
        ))

<?php

namespace App\Command;

use Psr\Log\LoggerInterface;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class LogCommand extends Command
{
    /** @var LoggerInterface */
    private $logger;

    public function __construct(LoggerInterface $logger)
    {
        parent::__construct('app:log');
        $this->logger = $logger;
    }

    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $this->logger->debug('Hi', [
            'debug' => 'some info'
        ]);
        $this->logger->info('Hi');
        $this->logger->notice('Hi');
        $this->logger->warning('Hi');
        $this->logger->error('Hi');
        $this->logger->critical('Hi');
        $this->logger->alert('Hi');
        $this->logger->emergency('Hi');
    }
}
